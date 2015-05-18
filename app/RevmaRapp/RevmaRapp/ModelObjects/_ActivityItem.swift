// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ActivityItem.swift instead.

import CoreData

public enum ActivityItemAttributes: String {
    case duration = "duration"
    case duty = "duty"
    case energy = "energy"
    case importance = "importance"
    case mastery = "mastery"
    case pain = "pain"
    case time_start = "time_start"
}

public enum ActivityItemRelationships: String {
    case activity = "activity"
    case period = "period"
}

@objc public
class _ActivityItem: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "ActivityLogItem"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _ActivityItem.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var duration: NSNumber?

    // func validateDuration(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var duty: NSNumber?

    // func validateDuty(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var energy: NSNumber?

    // func validateEnergy(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var importance: NSNumber?

    // func validateImportance(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var mastery: NSNumber?

    // func validateMastery(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var pain: NSNumber?

    // func validatePain(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var time_start: NSDate?

    // func validateTime_start(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

    @NSManaged internal
    var activity: ActivityName?

    // func validateActivity(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged internal
    var period: ActivityPeriod?

    // func validatePeriod(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

}

