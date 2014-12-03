//
//  ThirdViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 06/11/14.
//  Copyright (c) 2014 Norsk Regnesentral. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController, ActivityEditControllerDelegate {
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
    @IBOutlet weak var painValue: UIProgressView!
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
            painValue.setProgress(ai.pain!.floatValue, animated: true)
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let whichSegue = segue.identifier {
            switch (whichSegue) {
            case "editActivity":
                if let editController = segue.destinationViewController.topViewController as? ActivityEditController {
                    editController.title = NSLocalizedString("Edit Activity", comment: "Edit Activity Title")
                    editController.delegate = self
                    editController.activityItem = activityItem
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
}

