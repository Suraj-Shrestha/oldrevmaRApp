//
//  FirstViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 06/11/14.
//  Copyright (c) 2014 Norsk Regnesentral. All rights reserved.
//

import UIKit
import CoreData


class ActivityTableViewController: ActivityTableViewControllerBase, NSFetchedResultsControllerDelegate, ActivityEditControllerDelegate {

    var managedObjectContext : NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let ShowActivitySegueID = "showActivity"
    let CreateActivitySegueID = "createActivity"
    

    var period: ActivityPeriod? {
        didSet {
            fetchActivities()
            tableView.reloadData()
        }
    }

    @IBOutlet var doneButton: UIBarButtonItem!
    var activitiesByDays = [Int: [ActivityItem]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Are we completely empty? May as well show them the dialog to start editing.
        if activitiesByDays.isEmpty && animated {
            self.performSegueWithIdentifier(CreateActivitySegueID, sender: self)
        }
    }

    private func fetchActivities() {
        // Probably need to page this by date at some point as well, for now get me everything
        let fetchRequest = NSFetchRequest(entityName: ActivityItem.entityName())
        fetchRequest.predicate = NSPredicate(format: "\(ActivityItemRelationships.period.rawValue) == %@", argumentArray: [self.period!])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: ActivityItemAttributes.time_start.rawValue, ascending: false)]
        var error: NSError?
        if let results = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) {
            let activities = results as! [ActivityItem]
            activitiesByDays = [Int: [ActivityItem]]()
            if !activities.isEmpty {
                let calendar = NSCalendar.currentCalendar()
                var sectionNum = 0
                var currentDay = calendar.component(NSCalendarUnit.CalendarUnitDay, fromDate: activities[0].time_start!)
                var activitiesInDay:[ActivityItem] = []
                for activity in activities {
                    let day = calendar.component(NSCalendarUnit.CalendarUnitDay, fromDate: activity.time_start!)
                    if day != currentDay {
                        activitiesByDays[sectionNum] = activitiesInDay
                        sectionNum = sectionNum + 1
                        currentDay = day
                        activitiesInDay = []
                    }
                    activitiesInDay.append(activity)
                }
                // The last set of activities wasn't added, so do that here.
                activitiesByDays[sectionNum] = activitiesInDay
            }
        } else {
            println("Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Attempting to get activity names")
        }
    }

    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Get the detail view hooked up.
        if let whichSegue = segue.identifier {
            switch (whichSegue) {
            case ShowActivitySegueID:
                if let indexPath = self.tableView.indexPathForSelectedRow() {
                    let activity = self.activitiesByDays[indexPath.section]![indexPath.row]
                    if let activityViewController = segue.destinationViewController.topViewController as? ActivityViewController {
                        activityViewController.activityItem = activity
                    }
                }
            case CreateActivitySegueID:
                if let editController = segue.destinationViewController.topViewController as? ActivityEditController {
                    editController.period = period
                    editController.delegate = self
                }
            default:
                break;
            }
        }
    }

    // MARK: Table view controller functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tmp = activitiesByDays[section] {
            return tmp.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let activities = activitiesByDays[section] {
            let activity = activities[0]
            return titleDateFormatter.stringFromDate(activity.time_start!)
        }
        return NSLocalizedString("Missing section title!", comment: "Shouldn't happen, but if we somehow don't have a date for an activity")
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return activitiesByDays.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ActivityListItem", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, forActivity: self.activitiesByDays[indexPath.section]![indexPath.row])
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ActivityItem.SquareSize
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
