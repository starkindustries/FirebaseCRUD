//
//  FileDetailTableViewController.swift
//  FirebaseCRUD
//
//  Created by Zion Perez on 12/30/17.
//  Copyright © 2017 Zion Perez. All rights reserved.
//

import UIKit
import Firebase

class UserDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameCell: UITableViewCell?
    @IBOutlet weak var emailCell: UITableViewCell?
    @IBOutlet weak var userIdCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        usernameCell?.textLabel?.text = Auth.auth().currentUser?.displayName
        emailCell?.textLabel?.text = Auth.auth().currentUser?.email
        userIdCell?.textLabel?.text = Auth.auth().currentUser?.uid
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

