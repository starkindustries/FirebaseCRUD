//
//  FilesTableViewController.swift
//  FirebaseCRUD
//
//  Created by Zion Perez on 12/27/17.
//  Copyright © 2017 Zion Perez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class FilesTableViewController: UITableViewController, FUIAuthDelegate {
    
    var db: Firestore!
    var authUI: FUIAuth!
    var docIDs: [String] = [String]()
    var userId: String?
    var email: String?
    
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
        
        readData()
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
        print("VIEW DID APPEAR")
        signIn()
    }
    
    ////////////////////////////////////////
    // MARK:- FUIAuthDelegate and Sign in and out functions
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
        if let uid = user?.uid {
            print("SIGNED IN: " + uid)
            email = authUI.auth?.currentUser?.email
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
            self.tableView.reloadData()
        }
    }
    
    // Sign in
    // How to check if user has valid Auth Session Firebase iOS?
    // https://stackoverflow.com/questions/37738366/how-to-check-if-user-has-valid-auth-session-firebase-ios
    func signIn() {
        if let email = Auth.auth().currentUser?.email {
            // User logged in
            self.email = email
            self.tableView.reloadData()
        } else {
            // User Not logged in. Present AuthUI controller
            let authViewController = authUI!.authViewController()
            self.present(authViewController, animated: true){
                print("AUTH VIEW PRESENTED!")
            }
        }
    }
    
    // Sign out
    @IBAction func signOut(segue: UIStoryboardSegue) {
        print("SIGNING OUT!")
        do {
            try authUI.signOut()
            email = "Tap to sign in"
            self.tableView.reloadData()
        } catch {
            print("ERROR: " + error.localizedDescription)
        }
    }
    
    // open url: This opens the webpage (e.g. google, facebook) for the user to sign in.
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    // MARK:- CRUD Functions
    
    //////////////////////////
    // Create Data
    @IBAction func createData() {
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
    
    //////////////////////////
    // Read Data
    private func readData() {
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
    }
    
    //////////////////////////
    // Update Data
    @IBAction func updateData() {
        guard let userId = self.userId else { return }
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
    
    ////////////////////////////////////
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else {
            return "Files"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // User Info Section
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.userInfoCellId, for: indexPath)
            cell.textLabel?.text = email
            return cell
        } else { // Files Section
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.fileCellId, for: indexPath)            
            return cell
        }
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Constants.userDetailSegueId {
            let dest = segue.destination as! UserDetailTableViewController
            dest.email = email
        }
    }

    // didReceiveMemoryWarning()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
