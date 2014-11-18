//
//  SecondViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 06/11/14.
//  Copyright (c) 2014 Norsk Regnesentral. All rights reserved.
//

import UIKit
import CoreData

class ActivityEditController: UIViewController {

    @IBOutlet weak var activityNameEdit: UITextField!
    
    @IBOutlet weak var startDateButton: UIButton!
    
    @IBOutlet weak var durationButton: UIButton!
    
    @IBOutlet weak var energySlider: UISlider!
    
    @IBOutlet weak var importanceSlider: UISlider!
    
    @IBOutlet weak var dutySlider: UISlider!
    
    @IBOutlet weak var masterySlider: UISlider!
    
    @IBOutlet weak var painSlider: UISlider!
    var managedObjectContext: NSManagedObjectContext?
    
    var activityItem: ActivityItem? {
        didSet {
            if (managedObjectContext == nil) {
                managedObjectContext = activityItem!.managedObjectContext
            }
            self.configureView()
        }
    }
    
    func configureView() {
        if self.activityNameEdit == nil {
            return
        }
        if let localActivity = activityItem {
            if let activityName = localActivity.activity {
                activityNameEdit.text = activityName.name!
            } else {
                activityNameEdit.text = NSLocalizedString("Tap to choose activity", comment: "Empty Activity Name")
            }

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


}

