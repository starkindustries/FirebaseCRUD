//
//  FileDetailTableViewController.swift
//  FirebaseCRUD
//
//  Created by Zion Perez on 12/30/17.
//  Copyright © 2017 Zion Perez. All rights reserved.
//

import UIKit

class UserDetailTableViewController: UITableViewController {
        
    @IBOutlet weak var emailCell: UITableViewCell?
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailCell?.textLabel?.text = email
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

