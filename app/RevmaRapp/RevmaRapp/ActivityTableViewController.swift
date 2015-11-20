//
//  FirstViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 06/11/14.
//  Copyright (c) 2014 Norsk Regnesentral. All rights reserved.
//

import UIKit
import CoreData


class ActivityTableViewController: ActivityTableViewControllerBase, NSFetchedResultsControllerDelegate, ActivityEditControllerDelegate, HelpControllerEndDelegate {

    var managedObjectContext : NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let ShowActivitySegueID = "showActivity"
    let CreateActivitySegueID = "createActivity"
    let ShowHelpSegueID = "showHelp"
    let HelpFile = "what-is-revmarapp"

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

    override func viewWillAppear(animated: Bool) {
        if let navConroller = self.navigationController {
            navConroller.toolbarHidden = false
        }
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
        do {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            let activities = results as! [ActivityItem]
            activitiesByDays = [Int: [ActivityItem]]()
            if !activities.isEmpty {
                let calendar = NSCalendar.currentCalendar()
                var sectionNum = 0
                var currentDay:Int
                if #available(iOS 8.0, *) {
                    currentDay = calendar.component(NSCalendarUnit.Day, fromDate: activities[0].time_start!)
                } else {
                    let components = calendar.components(NSCalendarUnit.Day, fromDate: activities[0].time_start!)
                    currentDay = components.day
                }
                var activitiesInDay:[ActivityItem] = []
                for activity in activities {
                    let day:Int
                    if #available(iOS 8.0, *) {
                        day = calendar.component(NSCalendarUnit.Day, fromDate: activity.time_start!)
                    } else {
                        let components = calendar.components(NSCalendarUnit.Day, fromDate: activity.time_start!)
                        day = components.day
                    }
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
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Attempting to get activity names")
        }
    }

    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Get the detail view hooked up.
        if let whichSegue = segue.identifier {
            switch (whichSegue) {
            case ShowActivitySegueID:
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let activity = self.activitiesByDays[indexPath.section]![indexPath.row]
                    if let activityViewController = segue.destinationViewController as? ActivityViewController {
                        activityViewController.activityItem = activity
                    }
                }
            case CreateActivitySegueID:
                if let navigationController = segue.destinationViewController as? UINavigationController {
                    if let editController = navigationController.topViewController as? ActivityEditController {
                        editController.period = period
                        editController.delegate = self
                    }
                }
            case ShowHelpSegueID:
                if let navigationController = segue.destinationViewController as? UINavigationController {
                    if let helpController = navigationController.topViewController as? HelpViewController {
                        helpController.delegate = self
                        helpController.htmlFile = HelpFile
                    }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ActivityListItem", forIndexPath: indexPath) 
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

    // Mark: Helpview stuff
    func helpDone(controller: HelpViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
