@objc(ActivityItem)
class ActivityItem: _ActivityItem {

    enum GraphQuadrant: Int { case I = 1, II, III, IV }


    var quadrant : GraphQuadrant {
        if isGreen {
            return .I
        } else if isRed {
            return .II
        } else if importance!.doubleValue - 0.5 > 0 {
            return .III
        } else {
            ZAssert(importance!.doubleValue - 0.5 < 0, "Activity must be in Quadrant IV")
            return .IV
        }
    }

	// Custom logic goes here.
    var isGray : Bool { // For the lazy
        return !isGreen && !isRed
    }

    var isGreen: Bool {
        return duty!.doubleValue - 0.5 > 0 && importance!.doubleValue - 0.5 > 0
    }

    var isRed: Bool {
        return duty!.doubleValue - 0.5 < 0 && importance!.doubleValue - 0.5 < 0
    }

    var activityGraphDistance: Double {
        return hypot(duty!.doubleValue - 0.5, importance!.doubleValue - 0.5)
    }
}
