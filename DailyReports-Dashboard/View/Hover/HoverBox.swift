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
                    Text(tag)
                        .font(.caption)
                        .foregroundColor(.white)
                )
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovered = hovering
                    }
                }

            if isHovered && hasData {
                Text(boothName)
                    .font(.caption2)
                    .padding(6)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .offset(y: -40)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

