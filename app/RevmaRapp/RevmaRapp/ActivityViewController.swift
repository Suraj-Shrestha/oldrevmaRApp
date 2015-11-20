//
//  ThirdViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 06/11/14.
//  Copyright (c) 2014 Norsk Regnesentral. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController, ActivityEditControllerDelegate, HelpControllerEndDelegate {
    let EditActivitySegueID = "editActivity"

    var activityItem: ActivityItem? {
        didSet {
            configureView()
        }
    }
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var energyValue: UIProgressView!
    @IBOutlet weak var meaningValue: UIProgressView!
    @IBOutlet weak var dutyValue: UIProgressView!
    @IBOutlet weak var masteryValue: UIProgressView!
    @IBOutlet weak var activityImage: UIImageView!

    var dateFormatter: NSDateFormatter!
    var numberFormatter: NSNumberFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        numberFormatter = NSNumberFormatter()
        configureView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeChanged", name: NSCurrentLocaleDidChangeNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let navController = self.navigationController {
            navController.toolbarHidden = true
        }
    }
    
    func localeChanged() {
        configureView()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        if !isViewLoaded() {
            return
        }

        if let ai = activityItem {
            activityNameLabel.text = ai.activity!.visibleName()
            startTimeLabel.text = dateFormatter.stringFromDate(ai.time_start!)
            durationLabel.text = numberFormatter.stringFromNumber(ai.duration!.integerValue)
            energyValue.setProgress(ai.energy!.floatValue, animated: true)
            meaningValue.setProgress(ai.importance!.floatValue, animated: true)
            dutyValue.setProgress(ai.duty!.floatValue, animated: true)
            masteryValue.setProgress(ai.mastery!.floatValue, animated: true)
            activityImage.image = (UIApplication.sharedApplication().delegate as! AppDelegate).imageForActivity(ai)
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let whichSegue = segue.identifier {
            switch (whichSegue) {
            case EditActivitySegueID:
                if let navigationController = segue.destinationViewController as? UINavigationController {
                    if let editController = navigationController.topViewController as? ActivityEditController {
                        editController.title = NSLocalizedString("Edit Activity", comment: "Edit Activity Title")
                        editController.delegate = self
                        editController.activityItem = activityItem
                    }
                }
            default:
                break;
            }
        }
    }

    // MARK: ActivtyEditControllerDelegate
    func activtyEditControllerDidCancel(controller: ActivityEditController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    func activityEditControllerDidSave(controller: ActivityEditController) {
        controller.save()
        self.dismissViewControllerAnimated(true, completion: nil)
        configureView()
    }

    // Mark: HelpControllerDone
    func helpDone(controller: HelpViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

