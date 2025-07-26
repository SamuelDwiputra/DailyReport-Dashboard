//
//  ReportTimeSpikeChart.swift
//  DailyReports-Dashboard
//
//  Created by sam on 25/07/25.
//

import SwiftUI
import Charts
import FirebaseFirestore

struct HourlyReportData: Identifiable {
    let id = UUID()
    let hour: Int
    let count: Int
}

struct ReportTimeSpikeChart: View {
    @State private var hourlyData: [HourlyReportData] = []
    @State private var reports: [Report] = []
    @State private var selectedDate = Date()
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and date picker
            HStack {
                Text("Report Time Spike")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
                
                Spacer()
                
                DatePicker("Select Date",
                           selection: $selectedDate,
                           displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .scaleEffect(0.9)
                .colorScheme(.light)
                .tint(.black)
                .foregroundStyle(.black)
            }
            
            // Date display
            Text(selectedDate.formatted(date: .complete, time: .omitted))
                .font(.caption)
                .foregroundColor(.black)
            
            chartView
                .padding()
                .cornerRadius(10)
        }
        .padding(.top)
        .padding(.horizontal)
        .onAppear {
            getReports()
        }
        .onChange(of: selectedDate) { _ in
            updateHourlyData()
        }
    }
    
    private var chartView: some View {
        Chart(hourlyData) { item in
            LineMark(
                x: .value("Hour", item.hour),
                y: .value("Reports", item.count)
            )
            .foregroundStyle(Color.pink)
            .lineStyle(StrokeStyle(lineWidth: 3))
            
            AreaMark(
                x: .value("Hour", item.hour),
                y: .value("Reports", item.count)
            )
            .foregroundStyle(Color.pink.opacity(0.3))
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(values: .stride(by: 2)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let hour = value.as(Int.self) {
                        Text("\(String(format: "%02d", hour)):00")
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    Text("\(value.as(Int.self) ?? 0)")
                        .foregroundColor(.black)
                }
            }
        }
        .overlay(
            // Show message when no data
            Group {
                if hourlyData.allSatisfy({ $0.count == 0 }) {
                    Text("No reports for this date")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
        )
    }
    
    private func getReports() {
        db.collection("Reports").order(by: "reportTime").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting reports: \(error)")
                return
            }
            
            let newReports = snapshot?.documents.compactMap { document in
                try? document.data(as: Report.self)
            } ?? []
            
            self.reports = newReports
            updateHourlyData()
        }
    }
    
    private func updateHourlyData() {
        let calendar = Calendar.current
        
        // Filter reports for selected date only
        let selectedDateReports = reports.filter { report in
            calendar.isDate(report.reportTime, inSameDayAs: selectedDate)
        }
        
        // Group reports by hour
        var hourlyCounts: [Int: Int] = [:]
        
        for report in selectedDateReports {
            let hour = calendar.component(.hour, from: report.reportTime)
            hourlyCounts[hour, default: 0] += 1
        }
        
        // Create hourly data for all 24 hours
        var newHourlyData: [HourlyReportData] = []
        for hour in 0...23 {
            let count = hourlyCounts[hour] ?? 0
            newHourlyData.append(HourlyReportData(hour: hour, count: count))
        }
        
        self.hourlyData = newHourlyData
    }
}
