// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ActivityName.swift instead.

import CoreData

public enum ActivityNameAttributes: String {
    case i18nable = "i18nable"
    case name = "name"
}

public enum ActivityNameRelationships: String {
    case activityItems = "activityItems"
}

@objc public
class _ActivityName: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Activity"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _ActivityName.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var i18nable: NSNumber?

    // func validateI18nable(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var name: String?

    // func validateName(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

    @NSManaged public
    var activityItems: NSSet

}

extension _ActivityName {

    func addActivityItems(objects: NSSet) {
        let mutable = self.activityItems.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.activityItems = mutable.copy() as! NSSet
    }

    func removeActivityItems(objects: NSSet) {
        let mutable = self.activityItems.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
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

