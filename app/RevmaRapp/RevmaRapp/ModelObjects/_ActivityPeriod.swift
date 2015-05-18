// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ActivityPeriod.swift instead.

import CoreData

public enum ActivityPeriodAttributes: String {
    case comment = "comment"
    case name = "name"
    case start = "start"
    case stop = "stop"
}

public enum ActivityPeriodRelationships: String {
    case activityItems = "activityItems"
}

@objc public
class _ActivityPeriod: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Period"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _ActivityPeriod.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var comment: String?

    // func validateComment(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var name: String?

    // func validateName(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var start: NSDate?

    // func validateStart(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var stop: NSDate?

    // func validateStop(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

    @NSManaged public
    var activityItems: NSSet

}

extension _ActivityPeriod {

    func addActivityItems(objects: NSSet) {
        let mutable = self.activityItems.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as! Set<NSObject>)
        self.activityItems = mutable.copy() as! NSSet
    }

    func removeActivityItems(objects: NSSet) {
        let mutable = self.activityItems.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as! Set<NSObject>)
        self.activityItems = mutable.copy() as! NSSet
    }

    func addActivityItemsObject(value: ActivityItem!) {
        let mutable = self.activityItems.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.activityItems = mutable.copy() as! NSSet
    }

    func removeActivityItemsObject(value: ActivityItem!) {
        let mutable = self.activityItems.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.activityItems = mutable.copy() as! NSSet
    }

}

