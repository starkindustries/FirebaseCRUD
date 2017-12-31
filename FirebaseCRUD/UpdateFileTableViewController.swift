//
//  UpdateFileTableViewController.swift
//  FirebaseCRUD
//
//  Created by Zion Perez on 12/30/17.
//  Copyright © 2017 Zion Perez. All rights reserved.
//

import UIKit

class UpdateFileTableViewController: UITableViewController {

    @IBOutlet weak var fileIdLabel: UILabel?
    @IBOutlet weak var filenameTextField: UITextField?
    @IBOutlet weak var filedataTextView: UITextView?
    
    var fileId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let fid = fileId {
            self.navigationItem.title = "Edit File"
            fileIdLabel?.text = fid
            fileIdLabel?.textColor = UIColor.black
        } else {
            self.navigationItem.title = "Add New File"
            fileIdLabel?.text = "This will be auto-generated"
            fileIdLabel?.textColor = UIColor.gray
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
