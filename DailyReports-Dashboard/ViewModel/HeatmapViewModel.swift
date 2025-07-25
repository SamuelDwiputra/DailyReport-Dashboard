////
////  HeatmapViewModel.swift
////  DailyReports-Dashboard
////
////  Created by Yonathan Hilkia on 25/07/25.
////
//
//import FirebaseFirestore
//import SwiftUI
//
//class HeatmapManager: ObservableObject {
//    
//    @State private var selectedCategory = "trash"
//    @State private var boothTags: [String: String] = [:] // [locationID: tag]
//    @State private var reportCounts: [String: Int] = [:] // [tag: count]
//    @State private var reportListener: ListenerRegistration?
//    @State private var categoryMappings: [String: String] = [:] // [categoryName: categoryID]
//
//    private let categories = ["trash", "crowd", "queue"]
//
//    private var db = Firestore.firestore()
//    
//    func loadCategoryMappings() {
//        db.collection("Categories").getDocuments { snapshot, error in
//            guard let documents = snapshot?.documents, error == nil else {
//                print("❌ Failed to load categories: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            var mappings: [String: String] = [:]
//            for doc in documents {
//                let categoryID = doc.documentID
//                let categoryName = doc.data()["name"] as? String ?? ""
//                mappings[categoryName.lowercased()] = categoryID
//            }
//            
//            print("📂 Category Mappings:", mappings)
//            self.categoryMappings = mappings
//            
//            self.loadBoothTags()
//        }
//    }
//
//    func loadBoothTags() {
//        db.collection("Booths").getDocuments { snapshot, error in
//            guard let documents = snapshot?.documents, error == nil else {
//                print("❌ Failed to load booths: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            var mapping: [String: String] = [:]
//            for doc in documents {
//                let locationID = doc.documentID
//                let tag = doc.data()["tag"] as? String ?? ""
//                mapping[locationID] = tag
//            }
//            print("📌 Booth Tags Loaded:", mapping)
//
//            self.boothTags = mapping
//            self.listenToReports()
//        }
//    }
//
//    func listenToReports() {
//        reportListener?.remove()
//        reportCounts = [:]
//        
//        // Get the category ID for the selected category name
//        guard let categoryID = categoryMappings[selectedCategory] else {
//            print("❌ No category ID found for: \(selectedCategory)")
//            return
//        }
//        
//        print("🔍 Listening for categoryID: \(categoryID) (for category: \(selectedCategory))")
//
//        db.collection("Reports")
//            .whereField("categoryID", isEqualTo: categoryID)
//            .addSnapshotListener { snapshot, error in
//                guard let documents = snapshot?.documents, error == nil else {
//                    print("❌ Failed to listen to reports: \(error?.localizedDescription ?? "Unknown error")")
//                    return
//                }
//                
//                print("📄 Found \(documents.count) reports for categoryID: \(categoryID)")
//
//                var counts: [String: Int] = [:]
//                for doc in documents {
//                    let locationID = doc.data()["locationID"] as? String ?? ""
//                    
//                    if let tag = self.boothTags[locationID] {
//                        counts[tag, default: 0] += 1
//                        print("✅ Report at \(locationID) -> tag: \(tag)")
//                    } else {
//                        print("❌ No tag found for locationID: \(locationID)")
//                    }
//                }
//
//                self.reportCounts = counts
//                print("📊 Final Report Counts for \(self.selectedCategory):", counts)
//            }
//    }
//
//    func allBoothTagsSorted() -> [String] {
//        return Set(boothTags.values).sorted()
//    }
//
//    func opacity(for tag: String) -> Double {
//        let count = reportCounts[tag] ?? 0
//        switch count {
//        case 20...: return 1.0
//        case 15...19: return 0.7
//        case 10...14: return 0.5
//        case 5...9: return 0.3
//        case 1...4: return 0.1
//        default: return 0.05
//        }
//    }
//}
