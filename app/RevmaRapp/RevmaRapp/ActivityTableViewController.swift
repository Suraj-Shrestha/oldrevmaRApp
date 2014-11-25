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
    
    var activities:[ActivityItem] = [];

    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Get the detail view hooked up.
        if let whichSegue = segue.identifier {
            switch (whichSegue) {
            case "showActivity":
                if let indexPath = self.tableView.indexPathForSelectedRow() {
                    let object = self.activities[indexPath.row] as ActivityItem
                    (segue.destinationViewController as ActivityEditController).activityItem = object
                }
            case "createActivity":
                let newActivity = ActivityItem(managedObjectContext: managedObjectContext)
                if let editController = segue.destinationViewController.topViewController as? ActivityEditController {
                    editController.delegate = self
                    editController.activityItem = newActivity
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ActivityListItem", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let activity = self.activities[indexPath.row] as ActivityItem
        cell.textLabel.text = activity.activity?.name
    }
    
    // MARK: ActivtyEditControllerDelegate
    func activtyEditControllerDidCancel(controller: ActivityEditController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    func activityEditControllerDidSave(controller: ActivityEditController) {
        controller.save()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

