import UIKit

@objc(ActivityName)
class ActivityName: _ActivityName {
    
    // Custom logic goes here.
    func visibleName() -> String {
        if let tmpName = name {
            return NSLocalizedString(tmpName, comment: "")
        }
        return NSLocalizedString("Unnamed Activity", comment: "Activity Name was somehow not set, should never be visible included for robustness")
    }

}
