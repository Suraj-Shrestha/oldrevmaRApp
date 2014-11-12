// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ActivityItem.swift instead.

import CoreData

enum ActivityItemAttributes: String {
    case duration = "duration"
    case duty = "duty"
    case energy = "energy"
    case importance = "importance"
    case mastery = "mastery"
    case pain = "pain"
    case time_start = "time_start"
}

enum ActivityItemRelationships: String {
    case activity = "activity"
}

@objc
class _ActivityItem: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "ActivityLogItem"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _ActivityItem.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var duration: NSNumber?

    // func validateDuration(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var duty: NSNumber?

    // func validateDuty(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var energy: NSNumber?

    // func validateEnergy(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var importance: NSNumber?

    // func validateImportance(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var mastery: NSNumber?

    // func validateMastery(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var pain: NSNumber?

    // func validatePain(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var time_start: NSDate?

    // func validateTime_start(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var activity: ActivityName?

    // func validateActivity(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

