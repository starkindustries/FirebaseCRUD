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

protocol ReloadTableProtocol {
    func reloadTable()
    func deleteFile(at index: Int)
}

class FilesTableViewController: UITableViewController, FUIAuthDelegate, ReloadTableProtocol {
        
    var authUI: FUIAuth!
    
    var username: String?
    var email: String?
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialize FirebaseAuth        
        authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self
        // Set the providers
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        authUI?.providers = providers
        authUI?.isSignInWithEmailHidden = true
        
        // Set TableReloadDelegate. This lets FileManager reload this table when changes occur.
        FileManager.sharedInstance.reloadTableDelegate = self
        
        // Check if user is already signed in
        if let user = Auth.auth().currentUser {
            // User logged in
            userId = user.uid
            email = user.email
            username = user.displayName
            
            FileManager.sharedInstance.addFileListener()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Check if user is signed in.
        checkSignIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FileManager.sharedInstance.removeFileListener()
    }
    
    // protocol ReloadTableProtocol
    func reloadTable() {
        self.tableView.reloadData()
    }
    
    ////////////////////////////////////////
    // MARK:- FUIAuthDelegate and Sign in and out functions
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        print("FIREBASE AUTH authUI(_:,didSignInWith:)")
        // handle user and error as necessary
        guard let uid = user?.uid else { return }
        
        userId = uid
        email = authUI.auth?.currentUser?.email
        username = authUI.auth?.currentUser?.displayName
        
        // Add a new document for the user
        FileManager.sharedInstance.addNewUser(userId: userId, email: email, name: username)
        FileManager.sharedInstance.addFileListener()
        
        reloadTable()
    }
    
    // Sign in
    // How to check if user has valid Auth Session Firebase iOS?
    // https://stackoverflow.com/questions/37738366/how-to-check-if-user-has-valid-auth-session-firebase-ios
    func isSignedIn() -> Bool {
        return (Auth.auth().currentUser != nil)
    }
    
    func checkSignIn() {
        print("FIREBASE AUTH signIn()")
        if let user = Auth.auth().currentUser {
            // User logged in
            userId = user.uid
            email = user.email
            username = user.displayName
            FileManager.sharedInstance.addFileListener()
        } else {
            // User Not logged in. Present AuthUI controller
            let authViewController = authUI.authViewController()
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
            FileManager.sharedInstance.removeFileListener()
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
            print("Updating File: name[\(filename)] data[\(filedata)]")
            FileManager.sharedInstance.updateFile(fileId: id, filename: filename, filedata: filedata)
        } else {
            FileManager.sharedInstance.createFile(filename: filename, filedata: filedata)
        }
    }
    
    @IBAction func cancelUpdateFile(segue: UIStoryboardSegue) {
        // Do nothing
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
            if isSignedIn() {
                return FileManager.sharedInstance.fileCount
            }
            return 0
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
            let file = FileManager.sharedInstance.getFile(at: indexPath.row)
            cell.textLabel?.text = file.filename
            return cell
        }
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            print("DELETING ROW: \(indexPath.description)")
            FileManager.sharedInstance.deleteFile(at: indexPath.row)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // ReloadTableProtocol
    func deleteFile(at index: Int) {
        print("ReloadTableProtocol: deleteFile()")
        let indexPath = IndexPath(row: index, section: 1)
        tableView.deleteRows(at: [indexPath], with: .fade)
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
            // do nothing
        } else if segue.identifier == Constants.fileDetailSegueId {
            if let row = self.tableView.indexPathForSelectedRow?.row {
                let file = FileManager.sharedInstance.getFile(at: row)
                let dest = segue.destination as! FileDetailTableViewController
                dest.filename = file.filename
                dest.fileData = file.filedata
                dest.fileId = file.fileId
            }
        } 
    }
    
    // didReceiveMemoryWarning()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
