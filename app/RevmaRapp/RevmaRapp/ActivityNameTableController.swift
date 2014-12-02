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

class ActivityNameTableController : UITableViewController, NSFetchedResultsControllerDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet var nameTable: UITableView!
    var managedObjectContext : NSManagedObjectContext?;
    
    var activityNames: [ActivityName] = []
    var selectedName: ActivityName? {
        didSet {
            doneButton.enabled = selectedName != nil
        }
    }
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
            // I would love to use UIAlertController here, but things should probably run on earlier versions of iOS
            // Thankfully, a port to UIAlertController is pretty straightforward.
            let alert = UIAlertView(title: NSLocalizedString("Create a New Activity", comment:"title for create activity alert"),
                                       message: NSLocalizedString("What's the name of the new activity?)", comment:""),
                                       delegate: self,
                                       cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel button"))
            alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
            alert.addButtonWithTitle(NSLocalizedString("OK", comment: "OK Button"))
            alert.show()
        } else {
            updateCellCheckmarkForTableView(tableView, indexPath: indexPath)
        }
    }
    
    func updateCellCheckmarkForTableView(tableView: UITableView, indexPath: NSIndexPath) {
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
    
    // MARK AlertView Delegate functions
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            return
        }
        
        if let newName = alertView.textFieldAtIndex(0)?.text {
            // Get rid of duplicates, when we can. Someone may have actually put this in already, so there's no point
            // in having it in again (we will select it for them though).
            // This doesn't solve any sort of translation issues. Those poor souls are on their own.
            let lowerNewName = newName.lowercaseString
            var row = 0
            for name in activityNames {
                if lowerNewName == NSLocalizedString(name.name!, comment: "").lowercaseString {
                    let indexPath = NSIndexPath(forRow: row, inSection: 0)
                    updateCellCheckmarkForTableView(nameTable, indexPath: indexPath) // This also updates selected name to be correct
                    nameTable.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    return
                }
                ++row
            }
            // Otherwise, do the creation
            let newActivityName = ActivityName(managedObjectContext: managedObjectContext)
            newActivityName.name = newName
            var error: NSError?
            managedObjectContext?.save(&error)
            ZAssert(error == nil, "Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Attempting to save new activity")
            fetchActivityNames()
            selectedName = newActivityName
            nameTable.reloadData()
        }
    }
}