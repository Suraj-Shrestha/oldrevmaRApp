//
//  ActivityTableViewControllerBase.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 22/06/15.
//  Copyright (c) 2015 Norsk Regnesentral. All rights reserved.
//

import Foundation

class ActivityTableViewControllerBase: UITableViewController {
    var titleDateFormatter: NSDateFormatter!
    var cellDateFormatter: NSDateFormatter!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleDateFormatter = NSDateFormatter()
        titleDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        titleDateFormatter.timeStyle = NSDateFormatterStyle.NoStyle

        cellDateFormatter = NSDateFormatter()
        cellDateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        cellDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    }

    final func configureCell(cell: UITableViewCell, forActivity activity:ActivityItem) {
        cell.detailTextLabel!.text =  cellDateFormatter.stringFromDate(activity.time_start!)
        if let cellText = activity.activity?.name {
            cell.textLabel!.text = activity.activity!.visibleName()
        } else {
            cell.textLabel!.text = NSLocalizedString("Missing activity name", comment: "Data corruption string, activities should always have a name")
        }
        cell.imageView!.image = (UIApplication.sharedApplication().delegate as! AppDelegate).imageForActivity(activity)
    }

    private func multiplierByDuration(duration: CGFloat) -> CGFloat {
        // These numbers should probably be examined a bit closer, I'm just doing some guessing here.
        switch duration {
        case 0...20:
            return 1
        case 21...40:
            return 1.25
        case 41...55:
            return 1.5
        case 56...80:
            return 1.75
        case 81...1000:
            return 2
        default:
            return 1
        }
    }

    final func heightForActivity(activity: ActivityItem) -> CGFloat {
        let BaseHeight: CGFloat = 50.0
        return BaseHeight * multiplierByDuration(CGFloat(activity.duration!.doubleValue))
    }
}