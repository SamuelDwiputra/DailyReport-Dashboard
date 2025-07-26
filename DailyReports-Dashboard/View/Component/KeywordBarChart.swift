//
//  KeywordBarChart.swift
//  DailyReports-Dashboard
//
//  Created by sam on 25/07/25.
//
import SwiftUI
import Charts
import FirebaseFirestore

struct KeywordData: Identifiable {
    let id = UUID()
    let word: String
    let count: Int
}

struct KeywordBarChart: View {
    @State private var keywordCounts: [KeywordData] = []

    private let db = Firestore.firestore()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Top Keywords")
                .font(.title3)
                .bold()
                .foregroundColor(.black)

            Chart(keywordCounts) { item in
                BarMark(
                    x: .value("Count", item.count),
                    y: .value("Keyword", item.word)
                )
                .foregroundStyle(Color("Red"))
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(.clear)
                    AxisValueLabel()
                        .foregroundStyle(.black)
                        .font(.caption)
                }
            }
            .chartXAxis {
                let max = Double(keywordCounts.map { $0.count }.max() ?? 1)
                AxisMarks(values: Array(stride(from: 0, through: max + 1, by: 1))) { value in
                    AxisGridLine().foregroundStyle(.clear)
                    AxisValueLabel()
                        .foregroundStyle(.black)
                        .font(.caption)
                }
            }
            .frame(height: CGFloat(keywordCounts.count * 28 + 60))
        }
        .padding()
        .onAppear {
            fetchAndProcessKeywords()
        }
    }

    func fetchAndProcessKeywords() {
        db.collection("Reports").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("❌ Failed to fetch reports for keywords")
                return
            }

            let descriptions: [String] = documents.compactMap {
                $0.data()["description"] as? String
            }

            let combinedText = descriptions.joined(separator: " ").lowercased()
            let words = combinedText
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty && $0.count > 1 }

            let wordCounts = Dictionary(grouping: words, by: { $0 })
                .mapValues { $0.count }

            let topWords = wordCounts
                .sorted { $0.value > $1.value }
                .prefix(5) // ✅ only show top 5
                .map { KeywordData(word: $0.key, count: $0.value) }

            DispatchQueue.main.async {
                self.keywordCounts = topWords
            }
        }
    }
}
