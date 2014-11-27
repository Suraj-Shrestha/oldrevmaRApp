//
//  ActivityNameTableController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 25/11/14.
//  Copyright (c) 2014 Norsk Regnesentral. All rights reserved.
//

import UIKit
import CoreData

protocol ActivityNameTableControllerDelegate {
    func activtyEditControllerDidCancel(controller: ActivityNameTableController)
    func activityEditControllerDidSave(controller: ActivityNameTableController)
}

class ActivityNameTableController : UITableViewController, NSFetchedResultsControllerDelegate {
    
    
    var managedObjectContext : NSManagedObjectContext?;
        
    var activityNames: [ActivityName] = []
    var selectedName: ActivityName?
    var delegate: ActivityNameTableControllerDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if activityNames.isEmpty {
            fetchActivityNames()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchActivityNames() {
        let fetchRequest = NSFetchRequest(entityName: ActivityName.entityName())
        var error: NSError?
        if let results = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) {
            activityNames = results as [ActivityName]
            activityNames.sort({ $0.name! < $1.name! })
        } else {
            println("Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Attempting to get activity names")
        }
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        if delegate != nil {
            delegate!.activtyEditControllerDidCancel(self)
        }
    }

    @IBAction func done(sender: UIBarButtonItem) {
        if delegate != nil {
            delegate!.activityEditControllerDidSave(self)
        }
    }
    
    // MARK: Table view controller functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // We have an extra row for the "create" item.
        return activityNames.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ActivityNameListItem", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
        
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if (indexPath.row < activityNames.count) {
            let name = activityNames[indexPath.row]
            cell.textLabel.text = NSLocalizedString(name.name!, comment:"")
            cell.accessoryType = (name == selectedName) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        } else {
            cell.textLabel.text = NSLocalizedString("Create a new activity…", comment: "Create new activity table cell")
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == activityNames.count) {
            // start another dialog and reload the model
            
        } else {
            var oldRow = -1
            var index = 0
            for name in activityNames {
                if name == selectedName {
                    oldRow = index;
                    break;
                }
                ++index
            }
            
            if oldRow == indexPath.row {
                return
            }
            
            if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                newCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                selectedName = activityNames[indexPath.row]
            }

            if let oldCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow:oldRow, inSection: 0)) {
                oldCell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
    }
}
