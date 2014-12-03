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

class ActivityEditController: UITableViewController, ActivityNameTableControllerDelegate {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // CellIDs
    let kDatePickerID = "datePicker"
    let kDateCellID = "dateCell"
    let kActivityNameCellID = "ActivityEditActivityName"
    let kDurationCellID = "durationCell"
    let kDurationPickerID = "durationPickerCell"
    let kQuestionCellID = "questionCell"
    let kQuestionCellAltID = "questionCellAlt"
    
    // Tags to pull out widgets
    let kDatePickerTag = 99
    let kDurationPickerTag = 100
    let kQuestionLabelTag = 500
    let kMinLabelTag = 501
    let kSliderTag = 502
    let kMaxLabelTag = 503

    // Rows for Section 0
    let kNameRow = 0
    let kDateRow = 1
    let kDatePickerRow = 2
    let kDurationRow = 3
    let kDurationPickerRow = 4

    // Rows for Section 1
    let kEnergyRow = 0
    let kMeaningRow = 1
    let kDutyRow = 2
    let kMasteryRow = 3
    let kPainRow = 4

    var valuesArray: [Float] = [0.5, 0.5, 0.5, 0.5, 0.5]

    var pickerCellRowHeight:CGFloat = 0.0
    var managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var delegate: ActivityEditControllerDelegate?
    var dateformater: NSDateFormatter!
    var datePickerIndexPath: NSIndexPath?
    var durationPickerIndexPath: NSIndexPath?
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
            valuesArray[kEnergyRow] = ai.energy!.floatValue
            valuesArray[kMeaningRow] = ai.importance!.floatValue
            valuesArray[kDutyRow] = ai.duty!.floatValue
            valuesArray[kMasteryRow] = ai.mastery!.floatValue
            valuesArray[kPainRow] = ai.pain!.floatValue
        } else {
            activityDate = NSDate()
            checkCanSave() // Make sure the done button is correct regardless of what was set.
        }
        tableView.reloadData()
        
    }
    
    func checkCanSave() {
        if (doneButton != nil) {
            doneButton.enabled = (activityName != nil) && (activityDate != nil)
        }

    }
    
    
    @IBAction func dateChanged(datePicker: UIDatePicker) {
        let targetedCellIndexPath = hasInlineDatePicker() ? NSIndexPath(forRow: datePickerIndexPath!.row - 1, inSection: 0) : tableView.indexPathForSelectedRow()
        if let cell = tableView.cellForRowAtIndexPath(targetedCellIndexPath) {
            activityDate = datePicker.date
            cell.detailTextLabel!.text = dateformater.stringFromDate(datePicker.date)
        }
    }
   
    @IBAction func sliderChanged(slider: UISlider) {
        var tableCell: UITableViewCell?
        // Walk up the tree to grab the tableviewcell
        var superview = slider.superview
        while superview != nil {
            if let tc = superview as? UITableViewCell {
                tableCell = tc
                break
            }
            superview = superview?.superview
        }
        if tableCell != nil {
            if let indexPath = tableView.indexPathForCell(tableCell!) {
                ZAssert(indexPath.section == 1, "Slider in another section than expected")
                valuesArray[indexPath.row] = slider.value
            }
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
    
    func hasInlineDurationPicker() -> Bool {
        return durationPickerIndexPath != nil
    }

    func indexPathHasPicker(indexPath: NSIndexPath) -> Bool {
        return datePickerIndexPath?.row == indexPath.row
    }
    
    func indexPathHasDate(indexPath: NSIndexPath) -> Bool {
        return indexPath.row == kDateRow || (hasInlineDatePicker() && indexPath == kDateRow + 1)
    }

    
    func save() {
        // Save this as a separate variable to stop us from cascading didSets.
        let activityToSave: ActivityItem = activityItem != nil ? activityItem : ActivityItem(managedObjectContext: managedObjectContext)
        activityToSave.activity = activityName
        activityToSave.time_start = activityDate
        activityToSave.pain = valuesArray[kPainRow]
        activityToSave.duty = valuesArray[kDutyRow]
        activityToSave.energy = valuesArray[kEnergyRow]
        activityToSave.mastery = valuesArray[kMasteryRow]
        activityToSave.importance = valuesArray[kMeaningRow]
        var error: NSError?
        managedObjectContext.save(&error)
        if let realError = error {
            println("Unresolved error \(realError.localizedDescription), \(realError.userInfo)\n Trying to save activity")
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
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return indexPathHasPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight
        }
        return 80
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return hasInlineDatePicker() ? 3 : 2
//            return hasInlineDatePicker() || hasInlineDurationPicker() ? 4 : 3
        }
        
        return valuesArray.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case kDateRow:
                let tableCell = tableView.dequeueReusableCellWithIdentifier(kDateCellID) as UITableViewCell
                tableCell.detailTextLabel!.text = dateformater.stringFromDate(activityDate!)
                return tableCell
            case kDatePickerRow:
                return tableView.dequeueReusableCellWithIdentifier(kDatePickerID) as UITableViewCell
            case kNameRow:
                fallthrough
            default:
                let tableCell = tableView.dequeueReusableCellWithIdentifier(kActivityNameCellID) as UITableViewCell
                if activityName?.name != nil {
                    tableCell.textLabel.text = activityName!.visibleName()
                } else {
                    tableCell.textLabel.text = NSLocalizedString("Tap to choose activity", comment: "Empty Activity Name")
                }
                return tableCell
            }
        }
        return configureQuestionCell(indexPath)
    }
    
    func configureQuestionCell(indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case kEnergyRow, kPainRow, kMasteryRow:
            let tableCell = tableView.dequeueReusableCellWithIdentifier(kQuestionCellID) as UITableViewCell
            let questionLabel = tableCell.viewWithTag(kQuestionLabelTag) as UILabel
            let minLabel = tableCell.viewWithTag(kMinLabelTag) as UIImageView
            let maxLabel = tableCell.viewWithTag(kMaxLabelTag) as UIImageView
            let slider = tableCell.viewWithTag(kSliderTag) as UISlider
            switch indexPath.row {
            case kEnergyRow:
                questionLabel.text = NSLocalizedString("Energy_use_label", comment: "Energy_use_label")
                minLabel.image = UIImage(named: "tongue-face")
                maxLabel.image = UIImage(named: "smile-face")
                slider.value = valuesArray[indexPath.row]
            case kPainRow:
                questionLabel.text = NSLocalizedString("Activity_pain_label", comment: "Activity_pain_label")
                minLabel.image = UIImage(named: "first")
                minLabel.frame = CGRectMake(minLabel.frame.origin.x, minLabel.frame.origin.y, 28, 28)
                maxLabel.image = UIImage(named: "first")
                slider.value = valuesArray[indexPath.row]
            case kMasteryRow:
                fallthrough
            default:
                questionLabel.text = NSLocalizedString("Activity_mastering_label", comment: "Activity_mastering_label")
                minLabel.image = UIImage(named: "thumbs-down")
                maxLabel.image = UIImage(named: "thumbs-up")
                slider.value = valuesArray[indexPath.row]
            }
            return tableCell
        case kMeaningRow, kDutyRow:
            let tableCell = tableView.dequeueReusableCellWithIdentifier(kQuestionCellAltID) as UITableViewCell
            let questionLabel = tableCell.viewWithTag(kQuestionLabelTag) as UILabel
            let minLabel = tableCell.viewWithTag(kMinLabelTag) as UILabel
            let maxLabel = tableCell.viewWithTag(kMaxLabelTag) as UILabel
            let slider = tableCell.viewWithTag(kSliderTag) as UISlider
            if indexPath.row == kMeaningRow {
                questionLabel.text = NSLocalizedString("Activity_duty_label", comment: "Activity_duty_label")
                minLabel.text = NSLocalizedString("Duty_label", comment: "Duty_label")
                maxLabel.text = NSLocalizedString("Desired_label", comment: "Desired_label")
                slider.value = valuesArray[indexPath.row]
            } else {
                questionLabel.text = NSLocalizedString("Activity_meaning_label", comment: "Activity_meaning_label")
                minLabel.text = NSLocalizedString("important_label", comment: "important_label")
                maxLabel.text = NSLocalizedString("unimportant_label", comment: "unimportant_label")
                slider.value = valuesArray[indexPath.row]
            }
            return tableCell
        default:
            return tableView.dequeueReusableCellWithIdentifier(kQuestionCellAltID) as UITableViewCell
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
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
