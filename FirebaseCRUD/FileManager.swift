//
//  FileManager.swift
//  FirebaseCRUD
//
//  Created by Zion Perez on 1/1/18.
//  Copyright © 2018 Zion Perez. All rights reserved.
//

import Foundation
import Firebase

class FileManager {
    // Singleton
    // https://krakendev.io/blog/the-right-way-to-write-a-singleton
    public static let sharedInstance = FileManager()
    
    // Private Init()
    // This prevents others from using the default '()' initializer for this class.
    private init() {
        // Initialize Firestore
        db = Firestore.firestore()        
    }
    
    // Vars
    var db: Firestore!
    var fileListener: ListenerRegistration?
    
    public var fileCount: Int {
        return files.count
    }
    private var files = [File]()
    var userId: String?
    
    var reloadTableDelegate: ReloadTableProtocol?
    
    //////////////////////////
    // Add New User
    // https://firebase.google.com/docs/firestore/manage-data/add-data
    func addNewUser(userId: String?, email: String?, name: String?) {
        guard let userId = userId else {
            print("Error addNewUser(): userId is nil.")
            return
        }
        
        let userData = ["userId": userId, "email": email ?? "", "name": name ?? ""]
        
        db.collection("users").document(userId).setData(userData) { err in
            if let err = err {
                print("Error adding user: \(err)")
            } else {
                print("User document added!")
            }
        }
    }
    
    //////////////////////////
    // Create File
    func createFile(filename: String?, filedata: String?) {
        guard let filename = filename, let filedata = filedata else {
            print("Error createFile(): Empty data set")
            return
        }
        guard let userId = userId else {
            print("Error createFile(): User is not signed in.")
            return
        }
        let file = File(uid: userId, name: filename, data: filedata)
        let documentData: [String: Any] = file.getDictionaryData()
        var docRef: DocumentReference? = nil
        docRef = db.collection("files").addDocument(data: documentData) { (error) in
            if let error = error {
                print("Error adding file: \(error)")
            } else {
                print("File added with ID: \(docRef!.documentID)")
            }
        }
    }
    
    //////////////////////////
    // Listen For Files (Read)
    //////////////////////////
    
    // File Listener
    func addFileListener() {
        guard let userId = userId else { fatalError() }
        fileListener = db.collection("files").whereField("userId", isEqualTo: userId).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.files = [File]()
            self.files = documents.map { (document) -> File in
                return File(data: document.data())
            }
            self.reloadTableDelegate?.reloadTable()
        }
    }
    
    func removeFileListener() {
        fileListener?.remove()
    }
    
    public func getFile(at index: Int) -> File {
        return files[index]
    }
    
    //////////////////////////
    // Update Data
    public func updateFile(fileId: String) {
        guard let userId = self.userId else {
            print("Error updateFile(_:): User is not signed in.")
            return
        }
        /*
         db.collection("users").document(userId).updateData([
         "userId": authUI.auth?.currentUser?.uid ?? "",
         "email": authUI.auth?.currentUser?.email ?? "",
         "name": authUI.auth?.currentUser?.displayName ?? "Anonymous"
         ]) { (error) in
         if let error = error {
         print("ERROR: " + error.localizedDescription)
         } else {
         print("Data saved!.")
         }
         }*/
    }
}
