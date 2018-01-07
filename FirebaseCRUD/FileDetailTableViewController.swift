//
//  FileDetailTableViewController.swift
//  FirebaseCRUD
//
//  Created by Zion Perez on 12/30/17.
//  Copyright © 2017 Zion Perez. All rights reserved.
//

import UIKit

class FileDetailTableViewController: UITableViewController {
    
    var fileId: String?
    var filename: String?
    var fileData: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = filename
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Filename"
        }
        return "File Data"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        } else {
            return 300
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.fileCellId, for: indexPath)
            cell.textLabel?.text = filename
            return cell
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.fileDataCellId, for: indexPath) as? FileDataTableViewCell {
                cell.textView.text = fileData
                return cell
            }
        }
        fatalError("cellForRowAt: Error loading tableViewCell")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Constants.editFileSegueId {
            let dest = segue.destination.childViewControllers.first as! UpdateFileTableViewController
            dest.fileId = fileId
            dest.filename = filename
            dest.filedata = fileData
        }
    }


}
