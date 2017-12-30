//
//  FileDetailTableViewController.swift
//  FirebaseCRUD
//
//  Created by Zion Perez on 12/30/17.
//  Copyright © 2017 Zion Perez. All rights reserved.
//

import UIKit

class UserDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameCell: UITableViewCell?
    @IBOutlet weak var emailCell: UITableViewCell?
    @IBOutlet weak var userIdCell: UITableViewCell?
    
    var username: String?
    var email: String?    
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameCell?.textLabel?.text = username
        emailCell?.textLabel?.text = email
        userIdCell?.textLabel?.text = userId
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

