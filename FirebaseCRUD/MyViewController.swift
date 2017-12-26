//
//  ViewController.swift
//  FirebaseCRUD
//
//  Created by Zion Perez on 12/25/17.
//  Copyright © 2017 Zion Perez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class MyViewController: UIViewController, FUIAuthDelegate {
    
    @IBOutlet weak var emailLabel: UILabel!
    
    var docIDs: [String] = [String]()
    var db: Firestore!
    var authUI: FUIAuth!
    var userId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        db = Firestore.firestore()
        
        // Initialize FirebaseAuth
        authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self
        // Set the providers
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        authUI?.providers = providers
        
        //////////////////////////
        // Read Data
        //////////////////////////
        if let uid = authUI.auth?.currentUser?.uid {
            let doc = db.collection("users").document(uid)
            print("DOC: " + doc.debugDescription)
            doc.getDocument(completion: { (querySnapshot, error) in
                if let error = error {
                    print("ERROR: " + error.localizedDescription)
                } else {
                    if let id = querySnapshot?.documentID {
                        print("ID: " + id)
                        self.userId = id
                    }
                }
            })
            
        }
        /*
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("**ERROR GETTING DOCUMENTS**: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.docIDs.append(document.documentID)
                }
            }
            print("doc IDs: " + self.docIDs.debugDescription)
        }*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // How to check if user has valid Auth Session Firebase iOS?
        // https://stackoverflow.com/questions/37738366/how-to-check-if-user-has-valid-auth-session-firebase-ios
        print("VIEW DID APPEAR")
        if let user = Auth.auth().currentUser?.email {
            // User logged in
            // Do nothing
            print("USER LOGGED IN: " + user)
        } else {
            // User Not logged in
            // Present AuthUI controller
            let authViewController = authUI!.authViewController()
            self.present(authViewController, animated: true){
                print("AUTH VIEW PRESENTED!")
            }
        }
    }
    
    @IBAction func signOut() {
        print("SIGNING OUT!")
        do {
            try authUI.signOut()
            emailLabel.text = "Not signed in"
        } catch {
            print("ERROR: " + error.localizedDescription)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
        if let uid = user?.uid {
            print("SIGNED IN: " + uid)
            emailLabel.text = authUI.auth?.currentUser?.email
            // Add a new document for the user
            var ref: DocumentReference? = nil
            ref = db.collection("users").addDocument(data: [
                "userId": authUI.auth?.currentUser?.uid ?? "",
                "email": authUI.auth?.currentUser?.email ?? "",
                "name": authUI.auth?.currentUser?.displayName ?? "Anonymous"
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
        }
    }
    
    @IBAction func createData() {
        //////////////////////////
        // Create Data
        //////////////////////////
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "userId": authUI.auth?.currentUser?.uid ?? "",
            "first": "Ada",
            "last": "Lovelace",
            "born": 1815
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
        // Add a second document with a generated ID.
        ref = db.collection("users").addDocument(data: [
            "userId": Auth.auth().currentUser?.uid ?? "",
            "first": "Alan",
            "middle": "Mathison",
            "last": "Turing",
            "born": 1912
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    @IBAction func updateData() {
        //////////////////////////
        // Update Data
        //////////////////////////
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
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
