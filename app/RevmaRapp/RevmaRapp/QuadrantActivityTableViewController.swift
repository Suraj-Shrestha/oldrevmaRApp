//
//  QuadrantActivityTableViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 22/06/15.
//  Copyright (c) 2015 Norsk Regnesentral. All rights reserved.
//

import UIKit

class QuadrantActivityTableViewController: ActivityTableViewControllerBase {
    let ShowActivitySegueID = "showActivity"
    var activities: [ActivityItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Table view controller functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ActivityListItem", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, forActivity: activities[indexPath.row])
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return heightForActivity(activities[indexPath.row])
    }

    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Get the detail view hooked up.
        if let whichSegue = segue.identifier {
            switch (whichSegue) {
            case ShowActivitySegueID:
                if let indexPath = self.tableView.indexPathForSelectedRow() {
                    let activity = self.activities[indexPath.row]
                    if let activityViewController = segue.destinationViewController.topViewController as? ActivityViewController {
                        activityViewController.activityItem = activity
                    }
                }
            default:
                break;
            }
        }
    }

}