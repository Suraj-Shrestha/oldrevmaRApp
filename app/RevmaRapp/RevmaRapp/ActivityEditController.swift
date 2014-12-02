//
//  SecondViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 06/11/14.
//  Copyright (c) 2014 Norsk Regnesentral. All rights reserved.
//

import UIKit
import CoreData

protocol ActivityEditControllerDelegate {
    func activtyEditControllerDidCancel(controller: ActivityEditController)
    func activityEditControllerDidSave(controller: ActivityEditController)
}

class ActivityEditController: UIViewController, UITableViewDataSource, UITableViewDelegate, ActivityNameTableControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
  
    @IBOutlet weak var energySlider: UISlider!
    
    @IBOutlet weak var importanceSlider: UISlider!
    
    @IBOutlet weak var dutySlider: UISlider!
    
    @IBOutlet weak var masterySlider: UISlider!
    
    @IBOutlet weak var painSlider: UISlider!

    
    let kDatePickerID = "datePicker";
    let kDateCellID = "dateCell"
    let kActivityNameID = "ActivityEditActivityName"
    let kDurationID = "durationCell"
    let kDatePickerTag = 99
    let kPickerAnimationDuration = 0.40
    let kNameRow = 0
    let kDateRow = 1
    let kDatePickerRow = 2
    
    var pickerCellRowHeight:CGFloat = 0.0
    var managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var delegate: ActivityEditControllerDelegate?
    var dateformater: NSDateFormatter!
    var datePickerIndexPath: NSIndexPath?
    var activityDate: NSDate?
    var activityName: ActivityName? {
        didSet {
            checkCanSave()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    var activityItem: ActivityItem! {
        didSet {
            self.configureView()
        }
    }
    
    func configureView() {
        if !isViewLoaded() {
            return
        }

        if let ai = activityItem {
            activityName = ai.activity
            activityDate = ai.time_start
            painSlider.setValue(ai.pain!.floatValue, animated: true)
            dutySlider.setValue(ai.duty!.floatValue, animated: true)
            energySlider.setValue(ai.energy!.floatValue, animated: true)
            masterySlider.setValue(ai.mastery!.floatValue, animated: true)
            importanceSlider.setValue(ai.importance!.floatValue, animated: true)
        } else {
            activityDate = NSDate()
            checkCanSave() // Make sure the done button is correct regardless of what was set.
        }
        
    }
    
    func checkCanSave() {
        if (doneButton != nil) {
            doneButton.enabled = (activityName != nil) && (activityDate != nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dateformater = NSDateFormatter()
        dateformater.dateStyle = NSDateFormatterStyle.ShortStyle
        dateformater.timeStyle = NSDateFormatterStyle.ShortStyle
        
        self.configureView()
        if let pickerViewCellToCheck = tableView.dequeueReusableCellWithIdentifier(kDatePickerID) as? UITableViewCell {
            pickerCellRowHeight = CGRectGetHeight(pickerViewCellToCheck.frame)
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeChanged", name: NSCurrentLocaleDidChangeNotification, object: nil)
    }
    
    func localeChanged() {
        configureView()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // DatePickerStuff
    func hasPickerForIndexPath(indexPath: NSIndexPath) -> Bool {
        let targetedRow = indexPath.row + 1
        if let checkDatePickerCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection:0)) {
            return checkDatePickerCell.viewWithTag(kDatePickerTag) != nil
        }
        return false
    }
    
    func updateDatePicker() {
        if datePickerIndexPath == nil {
            return
        }
        
        if let associatedDatePickerCell = tableView.cellForRowAtIndexPath(datePickerIndexPath!) {
            if let tmpDatePicker = associatedDatePickerCell.viewWithTag(kDatePickerTag) as? UIDatePicker {
                tmpDatePicker.setDate(activityDate!, animated: false)
            }
        }
    }
    
    func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }

    func indexPathHasPicker(indexPath: NSIndexPath) -> Bool {
        return datePickerIndexPath?.row == indexPath.row
    }
    
    func indexPathHasDate(indexPath: NSIndexPath) -> Bool {
        return indexPath.row == kDateRow || (hasInlineDatePicker() && indexPath == kDateRow + 1)
    }
    
    @IBAction func dateChanged(sender: UIDatePicker) {
        let targetedCellIndexPath = hasInlineDatePicker() ? NSIndexPath(forRow: datePickerIndexPath!.row - 1, inSection: 0) : tableView.indexPathForSelectedRow()
        if let cell = tableView.cellForRowAtIndexPath(targetedCellIndexPath) {
            activityDate = sender.date
            cell.detailTextLabel!.text = dateformater.stringFromDate(sender.date)
        }
    }
    
    func save() {
        // Save this as a separate variable to stop us from cascading didSets.
        let activityToSave: ActivityItem = activityItem != nil ? activityItem : ActivityItem(managedObjectContext: managedObjectContext)
        activityToSave.activity = activityName
        activityToSave.time_start = activityDate
        activityToSave.pain = painSlider.value
        activityToSave.duty = dutySlider.value
        activityToSave.energy = energySlider.value
        activityToSave.mastery = masterySlider.value
        activityToSave.importance = importanceSlider.value
        var error: NSError?
        managedObjectContext.save(&error)
        if let realError = error {
            println("Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Trying to save activity")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Get the detail view hooked up.
        if let whichSegue = segue.identifier {
            switch (whichSegue) {
            case "showActivityNames":
                if let nameTableController = segue.destinationViewController.topViewController as? ActivityNameTableController {
                    nameTableController.selectedName = activityName
                    nameTableController.managedObjectContext = managedObjectContext
                    nameTableController.delegate = self
                }
            default:
                break;
            }
        }
    }

    // MARK TableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPathHasPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasInlineDatePicker() ? 3 : 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.row) {
        case kDateRow:
            let tableCell = tableView.dequeueReusableCellWithIdentifier(kDateCellID) as UITableViewCell
            tableCell.detailTextLabel!.text = dateformater.stringFromDate(activityDate!)
            return tableCell
        case kDatePickerRow:
            return tableView.dequeueReusableCellWithIdentifier(kDatePickerID) as UITableViewCell
        case kNameRow:
            fallthrough
        default:
            let tableCell = tableView.dequeueReusableCellWithIdentifier(kActivityNameID) as UITableViewCell
            if activityName?.name != nil {
                tableCell.textLabel.text = activityName!.visibleName()
            } else {
                tableCell.textLabel.text = NSLocalizedString("Tap to choose activity", comment: "Empty Activity Name")
            }
            return tableCell
        }
    }
    
    func toggleDatePickerForSelectedIndexPath(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: 0)]
        
        if hasPickerForIndexPath(indexPath) {
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        }
        tableView.endUpdates()
    }

    func displayInlineDatePickerForRowAtIndexPath(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        let before = hasInlineDatePicker() ? datePickerIndexPath!.row < indexPath.row : false
        let sameCellClicked = datePickerIndexPath?.row == indexPath.row + 1
        
        if hasInlineDatePicker() {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: self.datePickerIndexPath!.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            datePickerIndexPath = nil
        }

        if !sameCellClicked {
            let rowToReveal = before ? indexPath.row - 1 : indexPath.row
            let indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: 0)
            toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            datePickerIndexPath = NSIndexPath(forRow: indexPathToReveal.row + 1, inSection: 0)
        }
        
        // always deselect the row containing the start or end date
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.endUpdates()
        updateDatePicker()
    }


    // MARK TableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == kDateCellID {
            displayInlineDatePickerForRowAtIndexPath(indexPath)
        }
    }
    // MARK ActivityNameTableController
    func activtyEditControllerDidCancel(controller: ActivityNameTableController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func activityEditControllerDidSave(controller: ActivityNameTableController) {
        activityName = controller.selectedName
        tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
