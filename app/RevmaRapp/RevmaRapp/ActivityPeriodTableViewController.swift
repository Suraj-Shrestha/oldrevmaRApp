//
//  ActivityPeriodTableViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 18/05/15.
//  Copyright (c) 2015 Norsk Regnesentral. All rights reserved.
//

import Foundation
import CoreData

class ActivityPeriodTableViewController : UITableViewController, NSFetchedResultsControllerDelegate {
    var managedObjectContext : NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var periods:[ActivityPeriod] = [];
    var dateFormatter: NSDateFormatter!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        fetchPeriods()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    final func fetchPeriods() {
        // Probably need to page this by date at some point as well, for now get me everything
        let fetchRequest = NSFetchRequest(entityName: ActivityPeriod.entityName())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: ActivityPeriodAttributes.start.rawValue, ascending: false)]
        var error: NSError?
        if let results = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) {
            periods = results as! [ActivityPeriod]
        } else {
            println("Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Attempting to get activity names")
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Get the detail view hooked up.
        if let whichSegue = segue.identifier {
            switch (whichSegue) {
            case "showPeriod":
                if let indexPath = self.tableView.indexPathForSelectedRow() {
                    let object = self.periods[indexPath.row] as ActivityPeriod
                    if let activityViewController = segue.destinationViewController.topViewController as? ActivityTableViewController {
                        activityViewController.period = object
                    }
                }
//            case "createPeriod":
//                if let editController = segue.destinationViewController.topViewController as? ActivityEditController {
//                    editController.delegate = self
//                }
            default:
                break;
            }
        }
    }
    
    // MARK: Table view controller functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periods.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PeriodListItem", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let period = self.periods[indexPath.row]
        if let cellText = period.name {
            cell.textLabel!.text = period.name
            cell.detailTextLabel!.text = "\(dateFormatter.stringFromDate(period.start!))–\(dateFormatter.stringFromDate(period.stop!))"
        } else {
            cell.textLabel!.text = NSLocalizedString("Missing period name", comment: "Data corruption string, periods should always have a name")
        }
    }

}