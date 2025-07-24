//
//  AuthManager.swift
//  DailyReports-Dashboard
//
//  Created by sam on 22/07/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isAdmin = false
    @Published var isLoading = true  // To show loading state
    @Published var email = ""
    @Published var password = ""
    
    private let db = Firestore.firestore()
    
    init() {
        // Check if user is already logged in when app starts
        self.isLoggedIn = Auth.auth().currentUser != nil
        
        // If user is logged in, check their role
        if let currentUser = Auth.auth().currentUser {
            checkUserRole(uid: currentUser.uid)
        } else {
            self.isLoading = false
        }
        
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.isLoggedIn = user != nil
                
                if let user = user {
                    // User logged in, check their role
                    self.checkUserRole(uid: user.uid)
                } else {
                    // User logged out, reset states
                    self.isAdmin = false
                    self.isLoading = false
                }
            }
        }
    }
    
    private func checkUserRole(uid: String) {
        isLoading = true
        
        db.collection("Users").document(uid).getDocument { document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    let data = document.data()
                    let role = data?["role"] as? String ?? "volunteer"
                    self.isAdmin = (role.lowercased() == "admin")
                } else {
                    print("User document not found or error: \(error?.localizedDescription ?? "Unknown error")")
                    self.isAdmin = false
                }
                self.isLoading = false
            }
        }
    }
    
     func login() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }

}
