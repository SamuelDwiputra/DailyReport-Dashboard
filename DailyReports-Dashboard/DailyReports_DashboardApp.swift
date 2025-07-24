//
//  DailyReports_DashboardApp.swift
//  DailyReports-Dashboard
//
//  Created by sam on 23/07/25.
//

import SwiftUI
import FirebaseCore


@main

struct DailyReports_DashboardApp: App {
    
    @StateObject private var authManager = AuthManager()
    init() {
           FirebaseApp.configure()
       }

    var body: some Scene {
        WindowGroup {
            Group{
                if authManager.isLoading {
                    ZStack {
                        Image("fd")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                    }.transition(.opacity)
                } else if authManager.isLoggedIn {
                   ReportView()
                } else {
                    LandingPageView()  // Login view
                  
                }
            }
            .animation(.easeInOut(duration: 1), value: authManager.isLoading)
            .animation(.easeInOut(duration: 1), value: authManager.isLoggedIn)
                .environmentObject(authManager)

        }
    }
}
