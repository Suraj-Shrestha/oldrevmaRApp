//
//  PeriodGraphChooserController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 23/06/15.
//  Copyright (c) 2015 Norsk Regnesentral. All rights reserved.
//

import UIKit
import CoreData

protocol PeriodGraphChooserControllerDelegate {
    func periodChooserControllerDidCancel(controller: PeriodGraphChooserController)
    func periodChooserControllerDidDone(controller: PeriodGraphChooserController)
}

class PeriodGraphChooserController: UITableViewController, NSFetchedResultsControllerDelegate {
    let PeriodCheckCellID = "PeriodCheckCell"
    var delegate: PeriodGraphChooserControllerDelegate? = nil
    var periods:[ActivityPeriod] = []
    var selectedPeriods = Set<ActivityPeriod>()
    var dataStore = (UIApplication.sharedApplication().delegate as! AppDelegate).dataStore
    var dateFormatter: NSDateFormatter!

    final func fetchPeriods() {
        periods = dataStore.fetchPeriods()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle

        fetchPeriods()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periods.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PeriodCheckCellID, forIndexPath: indexPath) 
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    private func configureCell(cell: UITableViewCell, atIndexPath indexPath:NSIndexPath) {
        let period = periods[indexPath.row]
        if let _ = period.name {
            cell.textLabel!.text = period.name
            cell.detailTextLabel!.text = "\(dateFormatter.stringFromDate(period.start!))–\(dateFormatter.stringFromDate(period.stop!))"
        } else {
            cell.textLabel!.text = NSLocalizedString("Missing period name", comment: "Data corruption string, periods should always have a name")
        }
        cell.accessoryType = selectedPeriods.contains(period) ? .Checkmark : .None
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        updateCellCheckmarkForTableView(tableView, indexPath: indexPath)
    }

    func updateCellCheckmarkForTableView(tableView: UITableView, indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let period = periods[indexPath.row]
        if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
            if newCell.accessoryType == .None {
                newCell.accessoryType = .Checkmark
                selectedPeriods.insert(period)
            } else {
                newCell.accessoryType = .None
                selectedPeriods.remove(period)
            }
        }
    }

    @IBAction func donePressed(sender: UIBarButtonItem) {
        delegate?.periodChooserControllerDidDone(self)
    }

    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        delegate?.periodChooserControllerDidCancel(self)
    }
}