//
//  ActivityPeriodEditController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 18/05/15.
//  Copyright (c) 2015 Norsk Regnesentral. All rights reserved.
//

import Foundation
import UIKit

protocol ActivityPeriodEditControllerDelegate {
    func periodEditControllerDidCancel(controller: ActivityPeriodEditController)
    func periodEditControllerDidSave(controller: ActivityPeriodEditController)
}

class ActivityPeriodEditController : UIViewController, UITextFieldDelegate {

    var delegate: ActivityPeriodEditControllerDelegate?
    var dayPeriod = -1
    var periodName = NSLocalizedString("New Period", comment: "Blank name for period")
    var startDate = NSDate()
    let OriginalScrollSize:CGFloat = 600.0
    let TextFieldScrollY:CGFloat = 770.0

    @IBOutlet weak var dayControl: UISegmentedControl!
    @IBOutlet weak var weekendWarningLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, OriginalScrollSize)
        startDate = datePicker.date
        datePicker.minimumDate = startDate.dateByAddingTimeInterval(-60 * 60 * 24)
        textField.text = periodName
        dayPeriod = dayControl.selectedSegmentIndex
        dayControl.setTitle(NSLocalizedString("3 days", comment: "3 day period"), forSegmentAtIndex: 0)
        dayControl.setTitle(NSLocalizedString("5 days", comment: "5 day period"), forSegmentAtIndex: 1)
        dayControl.setTitle(NSLocalizedString("7 days", comment: "7 day period"), forSegmentAtIndex: 2)
        fixWeekendWarning()
    }

    private func fixWeekendWarning() {
        if includesWeekend() {
            weekendWarningLabel.text = "";
        } else {
            weekendWarningLabel.text = NSLocalizedString("Period should include one day in a weekend", comment: "Warning to include a weekend.")
        }
    }

    @IBAction func doCancel(sender: UIBarButtonItem) {
        if let realDelegate = delegate {
            realDelegate.periodEditControllerDidCancel(self)
        }
    }

    private func includesWeekend() -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let weekday = calendar.component(NSCalendarUnit.WeekdayCalendarUnit, fromDate: startDate)

        // If we are more than 5 days, we must have a weekend day there.
        if dayPeriod > 5 {
            return true
        }

        // if we start on a weekend day or on a Thursday, we must cover the weekend
        if weekday == 1 || weekday >= 5 {
            return true
        }

        // If it's a five-day period, see that we start on Tuesday
        if dayPeriod == 5 && weekday > 2 {
            return true
        }
        
        // Otherwise, we don't have a weekend here.
        return false
    }

    @IBAction func dayPickerChanged(segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            dayPeriod = 3
        case 1:
            dayPeriod = 5
        case 2:
            dayPeriod = 7
        case UISegmentedControlNoSegment:
            fallthrough
        default:
            dayPeriod = -1
        }
        fixWeekendWarning()
    }

    @IBAction func startDateChanged(datePicker: UIDatePicker) {
        startDate = datePicker.date
        fixWeekendWarning()
    }

    @IBAction func donePressed(sender: UIBarButtonItem) {
        if includesWeekend() == false {
            // start another dialog and reload the model
            // I would love to use UIAlertController here, but things should probably run on earlier versions of iOS
            // Thankfully, a port to UIAlertController is pretty straightforward.
            let alert = UIAlertView(title: NSLocalizedString("The period should include a weekend", comment:"Weekend warning"),
                message: NSLocalizedString("Use this period anyway?", comment:""),
                delegate: self,
                cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel button"))
            alert.addButtonWithTitle(NSLocalizedString("Use Period", comment: "OK Button"))
            alert.show()
        } else {
            finishSave()
        }
    }

    @IBAction func periodNameChanged(textField: UITextField) {
        periodName = textField.text
    }

    // MARK AlertView Delegate functions
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            finishSave()
        }
    }

    private func finishSave() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        let period = ActivityPeriod(managedObjectContext: managedObjectContext)
        period.name = periodName
        period.start = startDate
        period.stop = startDate.dateByAddingTimeInterval(60.0 * 60.0 * 24.0 * Double(dayPeriod))
        appDelegate.saveContext()

        if let realDelegate = delegate {
            realDelegate.periodEditControllerDidSave(self)
        }
    }

    // Mark: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, OriginalScrollSize)
        scrollView.scrollRectToVisible(CGRectMake(0, 0, 10, 10), animated: true)
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 900)
        scrollView.scrollRectToVisible(CGRectMake(0, TextFieldScrollY, 10, 10), animated: true)
    }
}
