//
//  ActivityPeriodTableViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 18/05/15.
//  Copyright (c) 2015 Norsk Regnesentral. All rights reserved.
//

import Foundation
import CoreData

class ActivityPeriodTableViewController : UITableViewController, NSFetchedResultsControllerDelegate, ActivityPeriodEditControllerDelegate, HelpControllerEndDelegate {
    var dataStore = (UIApplication.sharedApplication().delegate as! AppDelegate).dataStore
    var periods:[ActivityPeriod] = [];
    var suppressCreatePeriodDialog = false
    var dateFormatter: NSDateFormatter!
    let CreatePeriodSegueID = "createPeriod"
    let ShowPeriodSegueID = "showPeriod"
    let ShowHelpSegueID = "showHelp"
    let HelpFile = "activity-periods"

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        fetchPeriods()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // No periods, well, show them a dialog then
        if periods.isEmpty && !suppressCreatePeriodDialog {
            self.performSegueWithIdentifier(CreatePeriodSegueID, sender: self)
        }
        if !animated {
            showFirstPeriod()
        }
    }
    
    final func fetchPeriods() {
        periods = dataStore.fetchPeriods()
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Get the detail view hooked up.
        if let whichSegue = segue.identifier {
            switch (whichSegue) {
            case ShowHelpSegueID:
                if let navigationController = segue.destinationViewController as? UINavigationController {
                    if let helpController = navigationController.topViewController as? HelpViewController {
                        helpController.delegate = self
                        helpController.htmlFile = HelpFile
                    }
                }
            case ShowPeriodSegueID:
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let period = self.periods[indexPath.row]
                    if let activityViewController = segue.destinationViewController as? ActivityTableViewController {
                        activityViewController.period = period
                    }
                }
            case CreatePeriodSegueID:
                if let navigationController = segue.destinationViewController as? UINavigationController {
                    if let editController = navigationController.topViewController as? ActivityPeriodEditController {
                        editController.delegate = self
                    }
                }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("PeriodListItem", forIndexPath: indexPath) 
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let period = self.periods[indexPath.row]
        if let _ = period.name {
            cell.textLabel!.text = period.name
            cell.detailTextLabel!.text = "\(dateFormatter.stringFromDate(period.start!))–\(dateFormatter.stringFromDate(period.stop!))"
        } else {
            cell.textLabel!.text = NSLocalizedString("Missing period name", comment: "Data corruption string, periods should always have a name")
        }
    }
    
    func periodEditControllerDidCancel(controller: ActivityPeriodEditController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        suppressCreatePeriodDialog = true
    }

    private func selectAndShow(indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
        self.performSegueWithIdentifier(ShowPeriodSegueID, sender: self)
    }
    
    private func showFirstPeriod() {
        if periods.count == 1 {
            // Select the first one because that's nice.
            selectAndShow(NSIndexPath(forRow: 0, inSection: 0))
        }
    }

    func periodEditControllerDidSave(controller: ActivityPeriodEditController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        fetchPeriods()
        tableView.reloadData()

        if let period = controller.savedPeriod {
            if let selectedIndex = periods.indexOf(period) {
                selectAndShow(NSIndexPath(forRow: selectedIndex, inSection: 0))
            }
        }
    }

    // HelpController delegate
    func helpDone(controller: HelpViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}