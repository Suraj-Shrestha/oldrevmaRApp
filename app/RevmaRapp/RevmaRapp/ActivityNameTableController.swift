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
        do {
            let results = try self.managedObjectContext?.executeFetchRequest(fetchRequest)
            activityNames = results as! [ActivityName]
            activityNames.sortInPlace({ $0.name! < $1.name! })
        } catch let error as NSError {
            print("Unresolved error \(error.localizedDescription), \(error.userInfo)\n Attempting to get activity names")
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ActivityNameListItem", forIndexPath: indexPath) 
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
        
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0) {
            cell.textLabel!.font = UIFont.boldSystemFontOfSize(cell.textLabel!.font.pointSize)
            cell.textLabel!.text = NSLocalizedString("Create a new activity…", comment: "Create new activity table cell")
        } else {
            let name = activityNames[indexPath.row - 1]
            cell.textLabel!.text = NSLocalizedString(name.name!, comment:"")
            cell.accessoryType = (name == selectedName) ? .Checkmark : .None
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0) {
            // start another dialog and reload the model
            // I would love to use UIAlertController here, but things should probably run on earlier versions of iOS
            // Thankfully, a port to UIAlertController is pretty straightforward.
            let alert = UIAlertView(title: NSLocalizedString("Create a New Activity", comment:"title for create activity alert"),
                                       message: NSLocalizedString("What's the name of the new activity?", comment:""),
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
        var index = 1 // Since the other activities in the table start at 1
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
            selectedName = activityNames[indexPath.row - 1]
        }
        
        if let oldCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow:oldRow, inSection: 0)) {
            oldCell.accessoryType = UITableViewCellAccessoryType.None
        }
        
    }
    
    func selectAndScrollToActivity(indexPath: NSIndexPath) {
        updateCellCheckmarkForTableView(tableView, indexPath: indexPath) // This also updates selected name to be correct
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
    }
    
    func trySelectForName(keyName: String, caseInSensitive: Bool) ->Bool {
        var row = 1 // Start at row 1 since create is the first.
        let keyCompareName = caseInSensitive ? keyName.lowercaseString : keyName
        for name in activityNames {
            let valueName = caseInSensitive ? NSLocalizedString(name.name!, comment: "").lowercaseString : NSLocalizedString(name.name!, comment: "")
            if keyCompareName == valueName {
                selectAndScrollToActivity(NSIndexPath(forRow: row, inSection: 0))
                return true
            }
            ++row
        }
        return false
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
            if trySelectForName(newName, caseInSensitive: true) == true {
                return
            }

            // Otherwise, do the creation and selection
            let newActivityName = ActivityName(managedObjectContext: managedObjectContext)
            newActivityName.name = newName
            var error: NSError?
            do {
                try managedObjectContext?.save()
            } catch let error1 as NSError {
                error = error1
            }
            ZAssert(error == nil, "Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Attempting to save new activity")
            fetchActivityNames()
            selectedName = newActivityName
            tableView.reloadData()
            // This will reload the tables, so we need to find the index again.
            trySelectForName(selectedName!.name!, caseInSensitive: true)
        }
    }
}
