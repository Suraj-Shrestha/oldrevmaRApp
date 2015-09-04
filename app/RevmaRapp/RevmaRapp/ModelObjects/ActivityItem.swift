@objc(ActivityItem)
class ActivityItem: _ActivityItem {

    enum GraphQuadrant: Int { case Unknown = 0, I = 1, II, III, IV }


    var quadrant : GraphQuadrant {
        let importanceAdjusted = importance!.doubleValue - 0.5
        let dutyAdjusted = duty!.doubleValue - 0.5
        if importanceAdjusted > 0 && dutyAdjusted > 0 {
            return .I
        } else if importanceAdjusted < 0 && dutyAdjusted < 0 {
            return .II
        } else if importanceAdjusted > 0 {
            return .III
        } else if importanceAdjusted < 0 {
            return .IV
        }
        return .Unknown
    }

    var isGreen: Bool {
        return energy!.doubleValue >= 0.5
    }

    var isRed: Bool {
        return energy!.doubleValue < 0.5
    }

    var activityGraphDistance: Double {
        return hypot(duty!.doubleValue - 0.5, importance!.doubleValue - 0.5)
    }

    var adjustedEnergyValue : Double {
        return ActivityItem.adjustedEnergyValueFor(energy!.doubleValue)
    }

    var durationAsSize : CGFloat {
        return ActivityItem.editSizeForDurationValue(duration!.doubleValue)
    }

    static let SquareSize: CGFloat = 120.0
    static func editSizeForDurationValue(rawDurationValue: Double) -> CGFloat {
        return 10 * sqrt(CGFloat(rawDurationValue))
    }

    static func adjustedEnergyValueFor(rawEnergyValue: Double) -> Double {
        return abs(rawEnergyValue - 0.5) + 0.1
    }
}
