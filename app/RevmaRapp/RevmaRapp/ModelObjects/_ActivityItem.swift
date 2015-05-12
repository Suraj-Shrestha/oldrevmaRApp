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

    // func validateDuration(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var duty: NSNumber?

    // func validateDuty(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var energy: NSNumber?

    // func validateEnergy(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var importance: NSNumber?

    // func validateImportance(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var mastery: NSNumber?

    // func validateMastery(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var pain: NSNumber?

    // func validatePain(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var time_start: NSDate?

    // func validateTime_start(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged internal
    var activity: ActivityName?

    // func validateActivity(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

