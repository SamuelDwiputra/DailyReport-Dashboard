//
//  CategoryPieChart.swift
//  DailyReports-Dashboard
//
//  Created by sam on 25/07/25.
//
import SwiftUI
import Charts
import FirebaseFirestore

struct CategoryReportData: Identifiable {
    let id = UUID()
    let categoryName: String
    let count: Int
    let percentage: Double
}

struct CategoryPieChart: View {
    @State private var categoryData: [CategoryReportData] = []
    @State private var categoryIDToName: [String: String] = [:]
    @State private var reports: [Report] = []
    @State private var isLoading = true
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Reports by Category")
                .font(.title3)
                .bold()
                .foregroundStyle(Color.black)
            
            HStack {
                pieChartView
                categoryLegend
                Spacer()
            }
            .padding()
            .cornerRadius(10)
        }
        .padding(.top)
        .padding(.horizontal)
        .onAppear {
            loadDataSequentially()
        }
        .task {
            loadDataSequentially()
        }
    }
    
    private var pieChartView: some View {
        Group {
            if isLoading || categoryData.isEmpty {
                ProgressView("Loading...")
                    .frame(width: 200, height: 200)
            } else {
                Chart(categoryData) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.4),
                        outerRadius: .ratio(0.9)
                    )
                    .foregroundStyle(colorForCategory(item.categoryName))
                    .opacity(0.8)
                }
                .frame(width: 200, height: 200)
            }
        }
    }
    
    private var categoryLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(categoryData) { item in
                legendItem(for: item)
            }
        }
        .padding(.leading)
    }
    
    private func legendItem(for item: CategoryReportData) -> some View {
        HStack {
            Circle()
                .fill(colorForCategory(item.categoryName))
                .frame(width: 12, height: 12)
            
            HStack() {
                Text("\(Int(item.percentage))%")
                    .font(.title2)
                    .foregroundColor(.black)
                Text(item.categoryName.capitalized)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
        }
    }
    
    // Load data sequentially to ensure proper order
    private func loadDataSequentially() {
        isLoading = true
        
        // First load category mappings
        loadCategoryMappings {
            // Then load reports after categories are loaded
            self.getReports()
        }
    }
    
    private func loadCategoryMappings(completion: @escaping () -> Void) {
        db.collection("Categories").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("❌ Failed to load categories: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            var idToName: [String: String] = [:]
            
            for doc in documents {
                let categoryID = doc.documentID
                let categoryName = doc.data()["name"] as? String ?? ""
                idToName[categoryID] = categoryName.lowercased()
            }
            
            DispatchQueue.main.async {
                self.categoryIDToName = idToName
                completion()
            }
        }
    }
    
    private func getReports() {
        db.collection("Reports").order(by: "reportTime").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting reports: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            let newReports = snapshot?.documents.compactMap { document in
                try? document.data(as: Report.self)
            } ?? []
            
            DispatchQueue.main.async {
                self.reports = newReports
                self.updateCategoryData()
            }
        }
    }
    
    private func updateCategoryData() {
        // Ensure we have category mappings before processing
        guard !categoryIDToName.isEmpty else {
            return
        }
        
        var categoryCounts: [String: Int] = [:]
        
        // Count reports by category
        for report in reports {
            if let categoryName = categoryIDToName[report.categoryID] {
                categoryCounts[categoryName, default: 0] += 1
            }
        }
        
        let totalReports = categoryCounts.values.reduce(0, +)
        
        // Create category data with percentages
        var newCategoryData: [CategoryReportData] = []
        for (categoryName, count) in categoryCounts {
            let percentage = totalReports > 0 ? (Double(count) / Double(totalReports)) * 100 : 0
            newCategoryData.append(CategoryReportData(
                categoryName: categoryName,
                count: count,
                percentage: percentage
            ))
        }
        
        // Sort by count descending
        self.categoryData = newCategoryData.sorted { $0.count > $1.count }
        self.isLoading = false
    }
    
    private func colorForCategory(_ categoryName: String) -> Color {
        switch categoryName.lowercased() {
        case "trash":
            return .green
        case "crowd":
            return .red
        case "queue":
            return .blue
        default:
            return .gray
        }
    }
}
