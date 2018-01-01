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
    
    var files: [File] = [File]()
    
    var username: String?
    var email: String?
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialize Firebase and FirebaseAuth
        db = Firestore.firestore()
        authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self
        // Set the providers
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        authUI?.providers = providers
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Check if user is signed in.
        signIn()
        readData()
        readMoreData()
    }
    
    ////////////////////////////////////////
    // MARK:- FUIAuthDelegate and Sign in and out functions
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
        guard let uid = user?.uid else { return }
        
        userId = uid
        email = authUI.auth?.currentUser?.email
        username = authUI.auth?.currentUser?.displayName
        
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
    
    // Sign in
    // How to check if user has valid Auth Session Firebase iOS?
    // https://stackoverflow.com/questions/37738366/how-to-check-if-user-has-valid-auth-session-firebase-ios
    func signIn() {
        if let user = Auth.auth().currentUser {
            // User logged in
            userId = user.uid
            email = user.email
            username = user.displayName

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
            userId = ""
            username = ""
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
    
    // MARK:- @IBActions
    
    @IBAction func updateFile(segue: UIStoryboardSegue) {
        print("UPDATE FILE GOT HERE!")
        let source = segue.source as! UpdateFileTableViewController
        let filename = source.filenameTextField?.text
        let filedata = source.filedataTextView?.text
        if let id = source.fileId {
            // update file
        } else {
            createFile(filename: filename, filedata: filedata)
        }
    }
    
    @IBAction func cancelUpdateFile(segue: UIStoryboardSegue) {
        // Do nothing
    }
    
    // MARK:- CRUD Functions
    
    //////////////////////////
    // Create Data
    func createFile(filename: String?, filedata: String?) {
        guard let filename = filename, let filedata = filedata else {
            print("Error createFile(): Empty data set")
            return
        }
        guard let userId = authUI.auth?.currentUser?.uid else {
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
    // Read Data
    func readData() {
        guard let uid = authUI.auth?.currentUser?.uid else { return }
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
    
    func readMoreData() {
        db.collection("files").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("ERROR GETTING DOCUMENTS: \(err)")
            } else {
                self.files = [File]()
                for document in querySnapshot!.documents {
                    print("DOCUMENT: \(document.documentID) => \(document.data())")
                    let data: [String: Any] = document.data()                    
                    print("FILENAME: \(String(describing: data["filename"]))")
                    let file = File(data: data)
                    print(file.description)
                    self.files.append(file)
                }
                self.tableView.reloadData()
            }
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
            return files.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Signed in as"
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
            cell.textLabel?.text = self.files[indexPath.row].filename
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
            dest.userId = userId
            dest.email = email
            dest.username = username
        } else if segue.identifier == Constants.newFileSegueId {
            //let dest = segue.destination.childViewControllers.first as? UpdateFileTableViewController
        } else if segue.identifier == Constants.fileDetailSegueId {
            if let row = self.tableView.indexPathForSelectedRow?.row {
                let dest = segue.destination as! FileDetailTableViewController
                dest.filename = files[row].filename
                dest.fileData = files[row].filedata
            }
        }
    }
    
    // didReceiveMemoryWarning()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
