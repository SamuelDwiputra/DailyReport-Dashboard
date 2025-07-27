//
//  GalleryView.swift
//  DailyReports-Dashboard
//
//  Created by Yonathan Hilkia on 27/07/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct GalleryView: View {
    @StateObject private var firestoreManager = FirestoreManager()
    @State private var selectedCategory: String = "All"

    var filteredReports: [Report] {
        if selectedCategory == "All" {
            return firestoreManager.reports.filter { $0.imageURL != nil }
        } else {
            return firestoreManager.reports.filter { $0.categoryID == selectedCategory && $0.imageURL != nil }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {

            // Category Filter Picker
            Menu {
                Button("All") {
                    selectedCategory = "All"
                }
                ForEach(firestoreManager.categories, id: \.id) { category in
                    Button(category.name.capitalized) {
                        selectedCategory = category.id
                    }
                }
            } label: {
                HStack {
                       Text(selectedCategoryLabel())
                        .foregroundColor(.black)

                   }
                   .font(.headline)
                   .padding(.horizontal)
            }
            .padding(.bottom, 10)

            // Grid of Images
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 10)], spacing: 10) {
                    ForEach(filteredReports) { report in
                        if let urlString = report.imageURL, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 100)
                                    .clipped()
                                    .cornerRadius(8)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 120, height: 100)
                                    .overlay(
                                        ProgressView()
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.top)
            }
        }
        .padding()
        .onAppear {
            firestoreManager.showAllPictures()
            firestoreManager.showAllCategory()
        }
    }
    
    private func selectedCategoryLabel() -> String {
        if selectedCategory == "All" {
            return "Category: All"
        } else {
            return "Category: \(firestoreManager.categories.first(where: { $0.id == selectedCategory })?.name.capitalized ?? selectedCategory)"
        }
    }

}
