//
//  FirstViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 06/11/14.
//  Copyright (c) 2014 Norsk Regnesentral. All rights reserved.
//

import UIKit
import CoreData


class ActivityTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, ActivityEditControllerDelegate {
    
    var managedObjectContext : NSManagedObjectContext?;
    
    var dateFormatter: NSDateFormatter!

    @IBOutlet var doneButton: UIBarButtonItem!
    var activities:[ActivityItem] = [];

    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        fetchActivities()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchActivities() {
        // Probably need to page this by date at some point as well, for now get me everything
        let fetchRequest = NSFetchRequest(entityName: ActivityItem.entityName())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: ActivityItemAttributes.time_start.rawValue, ascending: false)]
        var error: NSError?
        if let results = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) {
            activities = results as! [ActivityItem]
            // Need to sort these things eventually, by date.
//            activities.sort({ $0.name! < $1.name! })
        } else {
            println("Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Attempting to get activity names")
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Get the detail view hooked up.
        if let whichSegue = segue.identifier {
            switch (whichSegue) {
            case "showActivity":
                if let indexPath = self.tableView.indexPathForSelectedRow() {
                    let object = self.activities[indexPath.row] as ActivityItem
                    if let activityViewController = segue.destinationViewController.topViewController as? ActivityViewController {
                        activityViewController.activityItem = object
                    }
                }
            case "createActivity":
                if let editController = segue.destinationViewController.topViewController as? ActivityEditController {
                    editController.delegate = self
                }
            default:
                break;
            }
        }
    }

    // MARK: Table view controller functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ActivityListItem", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let activity = self.activities[indexPath.row]
        if let cellText = activity.activity?.name {
            cell.textLabel!.text = activity.activity!.visibleName()

            cell.detailTextLabel!.text = dateFormatter.stringFromDate(activity.time_start!)
        } else {
            cell.textLabel!.text = NSLocalizedString("Missing activity name", comment: "Data corruption string, activities should always have a name")
        }

    }
    
    // MARK: ActivtyEditControllerDelegate
    func activtyEditControllerDidCancel(controller: ActivityEditController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    func activityEditControllerDidSave(controller: ActivityEditController) {
        controller.save()
        fetchActivities()
        tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

