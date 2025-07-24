//
//  Supabase.swift
//  DailyReport
//
//  Created by Yonathan Hilkia on 23/07/25.
//
import Foundation
import Supabase


import AppKit
public typealias PlatformImage = NSImage


class SupabaseManager {
    static let shared = SupabaseManager()

    private let client = SupabaseClient(
        supabaseURL: URL(string: "https://fwwlfmyclddmshezqnvq.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3d2xmbXljbGRkbXNoZXpxbnZxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMyMzMyMzEsImV4cCI6MjA2ODgwOTIzMX0.haVK_rKXwaw9YxmNg5vFjToi1YGU3mYKJavmHnSsWaU"
    )

   
}
