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

class ActivityEditController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var startDateButton: UIButton!
    
    @IBOutlet weak var durationButton: UIButton!
    
    @IBOutlet weak var energySlider: UISlider!
    
    @IBOutlet weak var importanceSlider: UISlider!
    
    @IBOutlet weak var dutySlider: UISlider!
    
    @IBOutlet weak var masterySlider: UISlider!
    
    @IBOutlet weak var painSlider: UISlider!
    var managedObjectContext: NSManagedObjectContext?
    var activityNames:[ActivityName] = []
    var delegate:ActivityEditControllerDelegate? = nil
    
    var activityItem: ActivityItem? {
        didSet {
            if (managedObjectContext == nil) {
                managedObjectContext = activityItem!.managedObjectContext
            }
            self.configureView()
        }
    }
    
    func configureView() {
        if self.managedObjectContext == nil {
            return
        }
        // Copy of all activity names? Sure.
        let fetchRequest = NSFetchRequest(entityName: ActivityName.entityName())
        var error: NSError?
        if let results = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) {
            activityNames = results as [ActivityName]
        } else {
            println("Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Attempting to get activity names")
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
        // write the stuff in and sync the database!!!
    }

    // MARK TableViewDataSource
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return 1
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let tableCell = tableView.dequeueReusableCellWithIdentifier("ActivityEditActivityName", forIndexPath: indexPath) as UITableViewCell
            
            if let localActivity = activityItem {
                if let activityName = localActivity.activity {
                    tableCell.textLabel.text = activityName.name!
                } else {
                    tableCell.textLabel.text = NSLocalizedString("Tap to choose activity", comment: "Empty Activity Name")
                }
            } else {
                tableCell.textLabel.text = NSLocalizedString("No activity!!!", comment: "No activity, this should not happen")
            }
            return tableCell
    }
    
    func tableView(tableView: UITableView,
        accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
            // ## Start the activity name viewer
    }


}
