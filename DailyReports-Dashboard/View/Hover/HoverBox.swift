//
//  HoverBox.swift
//  DailyReports-Dashboard
//
//  Created by Yonathan Hilkia on 25/07/25.
//

import SwiftUI
import FirebaseFirestore

struct HoverBox: View {
    let tag: String
    let boothName: String
    let opacity: Double
    let reportCount: Int

    @State private var isHovered = false

    var body: some View {
        
        let darkRedColor = NSColor(hex: "#DC143C")
        let grayColor = NSColor(hex: "#808080")
        let hasData = opacity > 0.1

        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hasData ? darkRedColor : grayColor))
                .opacity(hasData ? opacity : 0.3)
                .frame(width: 60, height: 50)
                .overlay(
                    VStack(spacing: 2) {
                        Text(tag)
                            .font(.caption)
                            .foregroundColor(.white)
                        Text("\(reportCount)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                )
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovered = hovering
                    }
                }

            if isHovered {
                VStack(spacing: 4) {
                    Text(boothName)
                        .font(.caption2)
                        .fontWeight(.medium)
                    Text("\(reportCount) Report\(reportCount == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(8)
                .background(Color.black.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(6)
                .offset(y: -50)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
