//
//  HeatmapView.swift
//  DailyReports-Dashboard
//
//  Created by Yonathan Hilkia on 24/07/25.
//
import SwiftUI
import FirebaseFirestore

struct HeatmapView: View {
    
    @State private var boothNamesByTag: [String: String] = [:] // tag: name
    @State private var isHovering = false
    @State private var selectedCategory = "trash"
    @State private var boothTags: [String: String] = [:] // [locationID: tag]
    @State var reportCounts: [String: Int] = [:] // [tag: count]
    @State private var reportListener: ListenerRegistration?
    @State private var categoryMappings: [String: String] = [:] // [categoryName: categoryID]

    private let db = Firestore.firestore()
    private let categories = ["trash", "crowd", "queue"]

    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
            Text("Booth Tracker")
                .font(.title)
                .foregroundColor(.black)
                .bold()
//                Text ("")
//                Spacer()
                .padding(.horizontal)
                Picker("" , selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category.capitalized).tag(category)
                    }
                }
                .foregroundColor(.black)
                .frame(width: 100, height: 50)
    //            .pickerStyle(.segmented)
                .padding(.vertical)
            }
            
            LazyVStack(spacing: 10) {
                            ForEach(groupedBoothTags().keys.sorted(), id: \.self) { letter in
                                // Row of paired booths for this letter
                                LazyHGrid(rows: [GridItem(.flexible())], spacing: 40) {
                                    ForEach(Array(pairTags(groupedBoothTags()[letter] ?? []).enumerated()), id: \.offset) { pairIndex, pair in
                                        HStack(spacing: 10) {
                                            ForEach(pair, id: \.self) { tag in
                                                HoverBox(
                                                    tag: tag,
                                                    boothName: boothNamesByTag[tag] ?? "Unknown",
                                                    opacity: opacity(for: tag)
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }
//            .background(Color.gray)
//            .opacity(0.5)
            .padding(.top)
            .padding(.bottom)
        }
        
        .background(
            (Color.white)
            .cornerRadius(8)
            .opacity(1)
//            .bold(true)
//                    )
            .cornerRadius(8)
        )
        .padding()
        .onAppear {
            loadCategoryMappings()
        }
        .onChange(of: selectedCategory) { _ in
            listenToReports()
        }
        .onDisappear {
            reportListener?.remove()
        }
    }

    
    func groupedBoothTags() -> [String: [String]] {
            let allTags = Set(boothTags.values).sorted()
            var grouped: [String: [String]] = [:]
            
            for tag in allTags {
                let firstLetter = String(tag.prefix(1)).uppercased()
                grouped[firstLetter, default: []].append(tag)
            }
            
            return grouped
        }
    
    private func pairTags(_ tags: [String]) -> [[String]] {
           var pairs: [[String]] = []
           for i in stride(from: 0, to: tags.count, by: 2) {
               let end = min(i + 2, tags.count)
               pairs.append(Array(tags[i..<end]))
           }
           return pairs
       }
    
    func loadCategoryMappings() {
        db.collection("Categories").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("❌ Failed to load categories: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            var mappings: [String: String] = [:]
            for doc in documents {
                let categoryID = doc.documentID
                let categoryName = doc.data()["name"] as? String ?? ""
                mappings[categoryName.lowercased()] = categoryID
            }
            
            print("📂 Category Mappings:", mappings)
            self.categoryMappings = mappings
            
            // Load booths after categories are loaded
            loadBoothTags()
        }
    }

    func loadBoothTags() {
        db.collection("Booths").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("❌ Failed to load booths: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            var mapping: [String: String] = [:]
            var nameMapping: [String: String] = [:]

            for doc in documents {
                let locationID = doc.documentID
                let tag = doc.data()["tag"] as? String ?? ""
                let name = doc.data()["name"] as? String ?? ""
                mapping[locationID] = tag
                nameMapping[tag] = name
            }
            print("📌 Booth Tags Loaded:", mapping)

            self.boothTags = mapping
            self.boothNamesByTag = nameMapping

            listenToReports()
        }
    }

    func listenToReports() {
        reportListener?.remove()
        reportCounts = [:]
        
        // Get the category ID for the selected category name
        guard let categoryID = categoryMappings[selectedCategory] else {
            print("❌ No category ID found for: \(selectedCategory)")
            return
        }
        
        print("🔍 Listening for categoryID: \(categoryID) (for category: \(selectedCategory))")

        db.collection("Reports")
            .whereField("categoryID", isEqualTo: categoryID)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("❌ Failed to listen to reports: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                print("📄 Found \(documents.count) reports for categoryID: \(categoryID)")

                var counts: [String: Int] = [:]
                for doc in documents {
                    let locationID = doc.data()["locationID"] as? String ?? ""
                    
                    if let tag = boothTags[locationID] {
                        counts[tag, default: 0] += 1
                        print("✅ Report at \(locationID) -> tag: \(tag)")
                    } else {
                        print("❌ No tag found for locationID: \(locationID)")
                    }
                }

                self.reportCounts = counts
                print("📊 Final Report Counts for \(selectedCategory):", counts)
            }
    }

    func allBoothTagsSorted() -> [String] {
        return Set(boothTags.values).sorted()
    }

    func opacity(for tag: String) -> Double {
        let count = reportCounts[tag] ?? 0
        switch count {
        case 21...: return 1.0
        case 15...20: return 0.8
        case 9...14: return 0.6
        case 1...8: return 0.3
        default: return 0.1
        }
    }
}
