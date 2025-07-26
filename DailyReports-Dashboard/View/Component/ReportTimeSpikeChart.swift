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
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Report Time Spike")
                .font(.title3)
                .bold()
                .foregroundColor(.black)
            
            chartView
                .padding()
                .cornerRadius(10)
        }.padding(.top)
            .padding(.horizontal)
        .background(
            Color.white
                .cornerRadius(8)
                .opacity(0.7)
        )
        .onAppear {
            getReports()
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
        let today = Date()
        
        // Filter reports for today only
        let todayReports = reports.filter { report in
            calendar.isDate(report.reportTime, inSameDayAs: today)
        }
        
        // Group reports by hour
        var hourlyCounts: [Int: Int] = [:]
        
        for report in todayReports {
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
