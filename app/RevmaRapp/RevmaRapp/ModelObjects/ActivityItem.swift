@objc(ActivityItem)
class ActivityItem: _ActivityItem {

    enum GraphQuadrant: Int { case Unknown = 0, I = 1, II, III, IV }


    var quadrant : GraphQuadrant {
        if isGreen {
            return .I
        } else if isRed {
            return .II
        } else if importance!.doubleValue - 0.5 > 0 {
            return .III
        } else if importance!.doubleValue - 0.5 < 0 {
            return .IV
        }
        return .Unknown
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

    var adjustedEnergyValue : Double {
        return abs(energy!.doubleValue - 0.5) + 0.1
    }
}
