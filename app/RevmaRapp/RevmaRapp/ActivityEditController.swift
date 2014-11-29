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
    
    @IBOutlet weak var nameTable: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    @IBOutlet weak var startDateButton: UIButton!
    
    @IBOutlet weak var durationButton: UIButton!
    
    @IBOutlet weak var energySlider: UISlider!
    
    @IBOutlet weak var importanceSlider: UISlider!
    
    @IBOutlet weak var dutySlider: UISlider!
    
    @IBOutlet weak var masterySlider: UISlider!
    
    @IBOutlet weak var painSlider: UISlider!
    var managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var delegate: ActivityEditControllerDelegate?
    var activityName: ActivityName? {
        didSet {
            checkCanSave()
        }
    }
    
    var activityItem: ActivityItem! {
        didSet {
            self.configureView()
        }
    }
    
    func configureView() {
        if activityItem?.activity != nil {
            activityName = activityItem.activity
        }
        
    }
    
    func checkCanSave() {
        if (doneButton != nil) {
            doneButton.enabled = (activityName != nil)
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
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func save() {
        if activityItem == nil {
            activityItem = ActivityItem(managedObjectContext: managedObjectContext)
        }
        activityItem.activity = activityName
        activityItem.pain = painSlider.value
        activityItem.duty = dutySlider.value
        activityItem.energy = energySlider.value
        activityItem.mastery = masterySlider.value
        activityItem.importance = masterySlider.value
        var error: NSError?
        managedObjectContext.save(&error)
        if let realError = error {
            println("Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Attempting to get activity names")
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCellWithIdentifier("ActivityEditActivityName", forIndexPath: indexPath) as UITableViewCell
        if let cellText = activityName?.name {
            tableCell.textLabel.text = NSLocalizedString(cellText, comment: "")
        } else {
            tableCell.textLabel.text = NSLocalizedString("Tap to choose activity", comment: "Empty Activity Name")
        }
        return tableCell
    }
    
    func tableView(tableView: UITableView,
        accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
            // ## Start the activity name viewer
    }

    // MARK ActivityNameTableController
    func activtyEditControllerDidCancel(controller: ActivityNameTableController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func activityEditControllerDidSave(controller: ActivityNameTableController) {
        activityName = controller.selectedName
        nameTable.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
