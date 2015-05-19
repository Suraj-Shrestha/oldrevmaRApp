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

class ActivityEditController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, ActivityNameTableControllerDelegate {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // CellIDs
    let kDatePickerID = "datePicker"
    let kDateCellID = "dateCell"
    let kActivityNameCellID = "ActivityEditActivityName"
    let kDurationCellID = "durationCell"
    let kDurationPickerID = "durationPickerCell"
    let kQuestionCellAltID = "questionCellAlt"
    
    // Tags to pull out widgets
    let kDatePickerTag = 99
    let kDurationPickerTag = 100
    let kQuestionLabelTag = 500
    let kMinLabelTag = 501
    let kSliderTag = 502
    let kMaxLabelTag = 503
    let kMinLabelTextTag = 504
    let kMaxLabelTextTag = 505

    // Rows for Section 0
    let kNameRow = 0
    let kDateRow = 1

    // Rows for Section 1
    let kMeaningRow = 0
    let kDutyRow = 1
    let kEnergyRow = 2
    let kMasteryRow = 3

    var pickerCellRowHeight:CGFloat = 0.0
    var managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var delegate: ActivityEditControllerDelegate?
    var dateFormater: NSDateFormatter!
    var numberFormatter: NSNumberFormatter!
    var datePickerIndexPath: NSIndexPath?
    var durationPickerIndexPath: NSIndexPath?
    
    // my actual model
    var valuesArray: [Float] = [0.5, 0.5, 0.5, 0.5]
    var activityDate: NSDate?
    var durationInMinutes: Int = 30
    var activityName: ActivityName? {
        didSet {
            checkCanSave()
        }
    }
    
    var activityItem: ActivityItem! {
        didSet {
            period = activityItem.period
            self.configureView()
        }
    }
    
    var period: ActivityPeriod!
    
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
            durationInMinutes = ai.duration!.integerValue
        } else {
            activityDate = NSDate()
        }
        checkCanSave() // Make sure the done button is correct regardless of what was set.
        tableView.reloadData()
        
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func checkCanSave() {
        if !isViewLoaded() {
            return
        }
        doneButton.enabled = activityName != nil && activityDate != nil
    }
    
    @IBAction func dateChanged(datePicker: UIDatePicker) {
        let targetedCellIndexPath = hasInlineDatePicker() ? NSIndexPath(forRow: datePickerIndexPath!.row - 1, inSection: 0) : tableView.indexPathForSelectedRow()
        if let cell = tableView.cellForRowAtIndexPath(targetedCellIndexPath) {
            activityDate = datePicker.date
            cell.detailTextLabel!.text = dateFormater.stringFromDate(datePicker.date)
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
        dateFormater = NSDateFormatter()
        dateFormater.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormater.timeStyle = NSDateFormatterStyle.ShortStyle
        
        numberFormatter = NSNumberFormatter()
        
        self.configureView()
        if let pickerViewCellToCheck = tableView.dequeueReusableCellWithIdentifier(kDatePickerID) as? UITableViewCell {
            pickerCellRowHeight = CGRectGetHeight(pickerViewCellToCheck.frame)
            // ### ARGH! I can't get the same contstraints on iOS 8.1… seems to work right on iOS 7, so fake it for now.
            // This is a bug waiting to happen later.
            if pickerCellRowHeight == 0 {
                pickerCellRowHeight = 216
            }
            
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
    
    // Duration Picker Stuff
    func hasDurationPickerForIndexPath(indexPath: NSIndexPath) -> Bool {
        let targetedRow = indexPath.row + 1
        if let checkDurationPickerCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection:0)) {
            return checkDurationPickerCell.viewWithTag(kDurationPickerTag) != nil
        }
        return false
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1 // Probably WAY to simple here
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 720 // 12 Hours in minutes, sure…
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        // Fix plurals correctly… eventrually
        if row == 0 {
            return NSLocalizedString("1 minute", comment: "Single minute")
        }
        return NSString(format: NSLocalizedString("%@ minutes", comment: "Multiple (@%) minutes"), "\(row + 1)") as String
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let targetedCellIndexPath = hasInlineDurationPicker() ? NSIndexPath(forRow: durationPickerIndexPath!.row - 1, inSection: 0) : tableView.indexPathForSelectedRow()
        if let cell = tableView.cellForRowAtIndexPath(targetedCellIndexPath) {
            durationInMinutes = row + 1
            cell.detailTextLabel!.text = numberFormatter.stringFromNumber(NSNumber(integer: durationInMinutes))
        }
    }

    func updateDurationPicker() {
        if durationPickerIndexPath == nil {
            return
        }
        
        if let associatiedDurationPickerCell = tableView.cellForRowAtIndexPath(durationPickerIndexPath!) {
            if let tmpPicker = associatiedDurationPickerCell.viewWithTag(kDurationPickerTag) as? UIPickerView {
                tmpPicker.selectRow(durationInMinutes - 1, inComponent: 0, animated: false)
            }
        }
    }

    func hasInlineDurationPicker() -> Bool {
        return durationPickerIndexPath != nil
    }

    func indexPathHasDurationPicker(indexPath: NSIndexPath) -> Bool {
        return durationPickerIndexPath?.section == indexPath.section && durationPickerIndexPath?.row == indexPath.row
    }

    func indexPathHasDuration(indexPath: NSIndexPath) -> Bool {
        if indexPath.section != 0 {
            return false
        }
        return hasInlineDatePicker() ? indexPath.row == kDateRow + 2 : indexPath.row == kDateRow + 1
    }

    // DatePickerStuff
    func hasDatePickerForIndexPath(indexPath: NSIndexPath) -> Bool {
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
    
    // Use a straight up comparison here since my index path's may be nil from time-to-time.
    func indexPathHasDatePicker(indexPath: NSIndexPath) -> Bool {
        return datePickerIndexPath?.section == indexPath.section && datePickerIndexPath?.row == indexPath.row
    }
    
    func indexPathHasDate(indexPath: NSIndexPath) -> Bool {
        if indexPath.section != 0 {
            return false
        }
        return indexPath.row == kDateRow
    }


    func save() {
        // Save this as a separate variable to stop us from cascading didSets.
        let activityToSave: ActivityItem = activityItem != nil ? activityItem : ActivityItem(managedObjectContext: managedObjectContext)
        if activityToSave.period == nil {
            activityToSave.period = period
        }
        activityToSave.activity = activityName
        activityToSave.time_start = activityDate
        activityToSave.duration = durationInMinutes
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
            return indexPathHasDatePicker(indexPath) || indexPathHasDurationPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight
        }
        assert(indexPath.section == 1, "Unknown section")
        // This needs to be updated someday, but for the moment the prototype cell can't handle being laid out at this point.
        // But in theory, this would be the right way to do this.
//        if self.prototypeCell == nil {
//            self.prototypeCell = tableView.dequeueReusableCellWithIdentifier(kQuestionCellAltID) as UITableViewCell
//        }
//        configureQuestionCellHelper(self.prototypeCell, forIndexPath: indexPath)
//        self.prototypeCell.layoutIfNeeded()
//        let size = self.prototypeCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return 110
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            var visibleRows = 3
            if hasInlineDatePicker() {
                ++visibleRows
            }
            if hasInlineDurationPicker() {
                ++visibleRows
            }
            return visibleRows
        }
        assert(section == 1, "Unknown section")
        return valuesArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if indexPathHasDatePicker(indexPath) {
                return tableView.dequeueReusableCellWithIdentifier(kDatePickerID) as! UITableViewCell
            }
            
            if indexPathHasDurationPicker(indexPath) {
                let tableCell = tableView.dequeueReusableCellWithIdentifier(kDurationPickerID) as! UITableViewCell
                if let picker = tableCell.viewWithTag(kDurationPickerTag) as? UIPickerView {
                    picker.delegate = self
                    picker.dataSource = self
                }
                return tableCell
            }
            
            if indexPathHasDate(indexPath) {
                let tableCell = tableView.dequeueReusableCellWithIdentifier(kDateCellID) as! UITableViewCell
                tableCell.detailTextLabel!.text = dateFormater.stringFromDate(activityDate!)
                tableCell.textLabel!.text = NSLocalizedString("Time_Start_Label", comment: "Time_Start_Label")
                return tableCell
            }
            
            if indexPathHasDuration(indexPath) {
                let tableCell = tableView.dequeueReusableCellWithIdentifier(kDurationCellID) as! UITableViewCell
                tableCell.detailTextLabel!.text = numberFormatter.stringFromNumber(NSNumber(integer: durationInMinutes))
                tableCell.textLabel!.text = NSLocalizedString("Duration_Label", comment: "Duration_Label")
                return tableCell
            }
            
            if indexPath.row == kNameRow {
                let tableCell = tableView.dequeueReusableCellWithIdentifier(kActivityNameCellID) as! UITableViewCell
                if activityName?.name != nil {
                    tableCell.textLabel!.text = activityName!.visibleName()
                } else {
                    tableCell.textLabel!.text = NSLocalizedString("Tap to choose activity", comment: "Empty Activity Name")
                }
                return tableCell
            }
        }
        return configureQuestionCell(indexPath)
    }

    func configureQuestionCellHelper(tableCell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        let questionLabel = tableCell.viewWithTag(kQuestionLabelTag) as! UILabel
        let minLabel = tableCell.viewWithTag(kMinLabelTag) as! UIImageView
        let maxLabel = tableCell.viewWithTag(kMaxLabelTag) as! UIImageView
        let minLabelText = tableCell.viewWithTag(kMinLabelTextTag) as! UILabel
        let maxLabelText = tableCell.viewWithTag(kMaxLabelTextTag) as! UILabel
        let slider = tableCell.viewWithTag(kSliderTag) as! UISlider
        slider.value = valuesArray[indexPath.row]
        switch indexPath.row {
        case kEnergyRow:
            questionLabel.text = NSLocalizedString("Energy_use_label", comment: "Energy_use_label")
            minLabel.image = UIImage(named: "tongue-face")
            maxLabel.image = UIImage(named: "smile-face")
            minLabelText.text = NSLocalizedString("energy_min_label", comment: "energy_min_label")
            maxLabelText.text = NSLocalizedString("energy_max_label", comment: "energy_max_label")
        case kDutyRow:
            questionLabel.text = NSLocalizedString("Activity_duty_label", comment: "Activity_duty_label")
            minLabelText.text = NSLocalizedString("duty_min_label", comment: "duty_min_label")
            maxLabelText.text = NSLocalizedString("duty_max_label", comment: "duty_max_label")
            minLabel.image = UIImage(named: "handshake")
            maxLabel.image = UIImage(named: "wish")
        case kMeaningRow:
            questionLabel.text = NSLocalizedString("Activity_meaning_label", comment: "Activity_meaning_label")
            maxLabelText.text = NSLocalizedString("meaning_max_label", comment: "meaning_max_label")
            minLabelText.text = NSLocalizedString("meaning_min_label", comment: "meaning_min_label")
            minLabel.image = UIImage(named: "unimportant")
            maxLabel.image = UIImage(named: "important")
        case kMasteryRow:
            fallthrough
        default:
            questionLabel.text = NSLocalizedString("Activity_mastering_label", comment: "Activity_mastering_label")
            minLabel.image = UIImage(named: "thumbs-down")
            maxLabel.image = UIImage(named: "thumbs-up")
            minLabelText.text = NSLocalizedString("mastering_min_label", comment: "mastering_min_label")
            maxLabelText.text = NSLocalizedString("mastering_max_label", comment: "mastering_max_label")
        }
    }

    
    func configureQuestionCell(indexPath: NSIndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCellWithIdentifier(kQuestionCellAltID) as! UITableViewCell
        configureQuestionCellHelper(tableCell, forIndexPath: indexPath)
        return tableCell
    }
    
    
    // Selection for the inline picker (Refactor this!)
    func toggleDurationPickerForSelectedIndexPath(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: 0)]
        
        if hasDurationPickerForIndexPath(indexPath) {
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        tableView.endUpdates()
    }
    
    func displayInlineDurationPickerForRowAtIndexPath(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        let before = hasInlineDurationPicker() ? durationPickerIndexPath!.row < indexPath.row : false
        let sameCellClicked = durationPickerIndexPath?.row == indexPath.row + 1
        
        if hasInlineDurationPicker() {
            tableView.deleteRowsAtIndexPaths([durationPickerIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            durationPickerIndexPath = nil
        }
        
        if !sameCellClicked {
            let rowToReveal = before ? indexPath.row - 1 : indexPath.row
            let indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: 0)
            toggleDurationPickerForSelectedIndexPath(indexPathToReveal)
            durationPickerIndexPath = NSIndexPath(forRow: indexPathToReveal.row + 1, inSection: 0)
        }
        
        // always deselect the row containing the start or end date
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        tableView.endUpdates()
        updateDurationPicker()
    }
    
    
    // Selection for the inline datepicker
    func toggleDatePickerForSelectedIndexPath(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: 0)]
        
        if hasDatePickerForIndexPath(indexPath) {
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
            self.tableView.deleteRowsAtIndexPaths([datePickerIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
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
        if let cellID = tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier {
            switch cellID {
            case kDateCellID:
                displayInlineDatePickerForRowAtIndexPath(indexPath)
            case kDurationCellID:
                displayInlineDurationPickerForRowAtIndexPath(indexPath)
            default:
                break
            }
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
