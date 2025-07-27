//
//  FirebaseViewModel.swift
//  DailyReports-Dashboard
//
//  Created by sam on 23/07/25.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct Category: Identifiable, Codable {
    var id: String
    var name: String
}

struct Report: Identifiable, Codable {
    @DocumentID var id: String?
    var categoryID: String
    var description: String
    var locationID: String
    var reportTime: Date
    var volunteerID: String
    var imageURL: String?
}

struct Booth: Identifiable, Codable {
    var id: String
    var hall: String
    var name: String
    var tag: String
}

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var role: String
}

struct Gallery: Identifiable, Codable {
    var id: String
    var url: String
}

class FirestoreManager: ObservableObject {
    
    private var db = Firestore.firestore()
    @Published var reports: [Report] = []
    @Published var categories: [Category] = []
    @Published var booths: [Booth] = []
    @Published var users: [User] = []
    @Published var currentUser: User?


    
    //create report
    func addReport(categoryID: String, description: String, locationID: String, reportTime: Date, volunteerID: String) {
        
        let newReport = Report(categoryID: categoryID, description: description, locationID: locationID, reportTime: reportTime, volunteerID: volunteerID)
        
        do {
            _ = try db.collection("Reports").addDocument(from: newReport)
        } catch {
            print("Error adding report: \(error)")
        }
    }
    
    // read reports
    func getReport() {
        db.collection("Reports").order(by: "reportTime").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting reports: \(error)")
                return
            }
            
            self.reports = snapshot?.documents.compactMap { document in
                try? document.data(as: Report.self)
            } ?? []
        }
    }
    
    // update reports
    func updateReport(report: Report) {
        guard let reportID = report.id else { return }
        
        do {
            try db.collection("Reports").document(reportID).setData(from: report)
        } catch {
            print("Error updating report: \(error)")
        }
    }
    
    
    // Delete reports
    func deleteReport(report: Report) {
        guard let reportID = report.id else { return }

        db.collection("Reports").document(reportID).delete { error in
            if let error = error {
                print("Error deleting reports: \(error)")
            }
        }
    }
    
    //showing data section for pickers and add form
    
    func showAllPictures() {
        db.collection("Reports").addSnapshotListener { snapshot, error in
            if let error = error {
                print("❌ Error getting reports: \(error.localizedDescription)")
                return
            }

            self.reports = snapshot?.documents.compactMap { document in
                let data = document.data()

                guard
                    let categoryID = data["categoryID"] as? String,
                    let description = data["description"] as? String,
                    let locationID = data["locationID"] as? String,
                    let timestamp = data["reportTime"] as? Timestamp,
                    let volunteerID = data["volunteerID"] as? String
                else {
                    print("⚠️ Skipping document \(document.documentID): Missing required fields")
                    return nil
                }

                let imageURL = data["imageURL"] as? String
                let reportTime = timestamp.dateValue()

                return Report(
                    id: document.documentID,
                    categoryID: categoryID,
                    description: description,
                    locationID: locationID,
                    reportTime: reportTime,
                    volunteerID: volunteerID,
                    imageURL: imageURL
                )
            } ?? []
        }
    }


    
    func showAllCategory() {
        db.collection("Categories").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting categories: \(error)")
                return
            }
            
            self.categories = snapshot?.documents.compactMap { document in
                guard let name = document.data()["name"] as? String else { return nil }
                return Category(id: document.documentID, name: name)
            } ?? []
        }
    }
    
    func showAllLocation() {
        db.collection("Booths").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting booths: \(error)")
                return
            }
            
            self.booths = snapshot?.documents.compactMap { document in
                guard let name = document.data()["name"] as? String,
                      let hall = document.data()["hall"] as? String,
                      let tag = document.data()["tag"] as? String else { return nil }
                return Booth(id: document.documentID, hall: hall, name: name, tag: tag)
            } ?? []
        }
    }
    
    func getCurrentUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
               print("⚠️ No authenticated user.")
               return
           }

           db.collection("Users").document(uid).getDocument { snapshot, error in
               if let error = error {
                   print("Error fetching current user: \(error)")
                   return
               }

               guard let data = snapshot?.data(),
                     let name = data["name"] as? String,
                     let role = data["role"] as? String else { return }

               self.currentUser = User(id: uid, name: name, role: role)
           }
    }
    
    //fetch section
    
    
    func getCategoryName(fromCategoryID categoryID: String, completion: @escaping (String) -> Void) {
        db.collection("Categories").document(categoryID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching category: \(error)")
                completion("Unknown Category")
                return
            }
            
            guard let data = snapshot?.data(),
                  let categoryName = data["name"] as? String else {
                print("⚠️ Category name not found.")
                completion("Unknown Category")
                return
            }
            
            completion(categoryName)
        }
    }
    
    func getCurrentVolunteerName(fromVolunteerID volunteerID: String, completion: @escaping (String) -> Void) {
        db.collection("Users").document(volunteerID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching category: \(error)")
                completion("Unknown Volunteer")
                return
            }
            
            guard let data = snapshot?.data(),
                  let volunteerName = data["name"] as? String else {
                print("⚠️ Volunteer name not found.")
                completion("Unknown Volunteer")
                return
            }
            
            completion(volunteerName)
        }
    }
    
    func getLocationName(fromLocationID locationID: String, completion: @escaping (String) -> Void) {
        db.collection("Booths").document(locationID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching category: \(error)")
                completion("Unknown Location")
                return
            }
            guard let data = snapshot?.data(),
                  let locationHall = data["hall"] as? String,
                  let locationName = data["name"] as? String,
                  let locationTag = data["tag"] as? String else
            {
                print("⚠️ Location not found.")
                completion("Unknown Location")
                return
            }
            let locationDetails = "Hall \(locationHall), \(locationName), \(locationTag)"
            completion(locationDetails)
        }
    }
}

// upload image

