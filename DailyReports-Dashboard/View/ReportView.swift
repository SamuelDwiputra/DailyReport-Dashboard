//
//  ReportView.swift
//  DailyReports-Dashboard
//
//  Created by sam on 24/07/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ReportView: View {
    @StateObject private var firestoreManager = FirestoreManager()
    @EnvironmentObject var authManager: AuthManager
    
    @State private var selectedPage: String = "Main"
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Sidebar
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Welcome to")
                        .font(.title2)
                        .foregroundColor(.white)
                        .italic(true)
                    Text("FD Reports")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .italic(true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
                .padding(.bottom, 40)
                
                // Navigation Menu
                VStack(alignment: .leading, spacing: 4) {
                    NavigationButton(title: "Main", isActive: selectedPage == "Main") {
                        selectedPage = "Main"
                    }
                    NavigationButton(title: "Volunteer", isActive: selectedPage == "Volunteer") {
                        selectedPage = "Volunteer"
                    }
                    NavigationButton(title: "Report History", isActive: selectedPage == "Report History") {
                        selectedPage = "Report History"
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: {
                    try? Auth.auth().signOut()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(width: 200)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.pink, Color.purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Main Content
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(selectedPage)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                .padding(.bottom, 20)
                
                ScrollView {
                    if selectedPage == "Main" {
                        HeatmapView()
                            .padding()
                    } else if selectedPage == "Report History" {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(firestoreManager.reports.enumerated()), id: \.element.id) { index, report in
                                ReportCardView(report: report, firestoreManager: firestoreManager, reportIndex: index + 1)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    } else {
                        Text("Coming soon: \(selectedPage)")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Grey"))
        }
        .onAppear {
            firestoreManager.getReport()
            firestoreManager.showAllCategory()
            firestoreManager.showAllLocation()
        }
    }
}

// MARK: - Navigation Button
struct NavigationButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .opacity(isActive ? 1.0 : 0.7)
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isActive ? Color.white.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct ReportCardView: View {
    let report: Report
    let firestoreManager: FirestoreManager
    let reportIndex: Int
    
    @State private var categoryName: String = "Loading..."
    @State private var volunteerName: String = "Loading..."
    @State private var locationDetails: String = "Loading..."
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Image if avail
            if let imageURL = report.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.system(size: 24))
                        )
                }
                .frame(width: 150, height: 120)
                .cornerRadius(8)
                .clipped()
            } else {
                // if no image
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 120)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    )
            }

            
            // Report Details
            VStack(alignment: .leading, spacing: 8) {
                
                
                // Report Number
                Text("Report No.\(String(format: "%05d", reportIndex))")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.black)
                
                // Category Badge
                HStack {
                    Text("Category :")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(categoryName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.teal)
                        .cornerRadius(12)
                }
                
                // Location
                HStack {
                    Text("Location :")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    Text(locationDetails)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                
                // Reporter
                HStack {
                    Text("Reporter :")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    Text(volunteerName)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                
                // Time
                HStack {
                    Text("Time :")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    Text(report.reportTime.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
            }
            
            Spacer()
            
            // Report Description
            VStack(alignment: .leading, spacing: 4) {
                Text("Description :\(report.description)")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                
                Spacer()
            }
            .frame(maxWidth: 300, alignment: .leading)
            
            Spacer()
            
            // Delete Button
            VStack {
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(6)
                .alert("Delete Report", isPresented: $showingDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        deleteReport()
                    }
                } message: {
                    Text("Are you sure you want to delete this report? This action cannot be undone.")
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onAppear {
            loadReportDetails()
        }
    }
    
    private func loadReportDetails() {
        firestoreManager.getCategoryName(fromCategoryID: report.categoryID) { name in
            DispatchQueue.main.async {
                self.categoryName = name
            }
        }
        
        firestoreManager.getCurrentVolunteerName(fromVolunteerID: report.volunteerID) { name in
            DispatchQueue.main.async {
                self.volunteerName = name
            }
        }
        
        firestoreManager.getLocationName(fromLocationID: report.locationID) { name in
            DispatchQueue.main.async {
                self.locationDetails = name
            }
        }
    }
    
    private func deleteReport() {
        // Add delete functionality here
        firestoreManager.deleteReport(report: report)
        print("Delete report: \(report.id ?? "unknown")")
    }
}
