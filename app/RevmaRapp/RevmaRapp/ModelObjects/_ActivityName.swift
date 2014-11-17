// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ActivityName.swift instead.

import CoreData

enum ActivityNameAttributes: String {
    case i18nable = "i18nable"
    case name = "name"
}

enum ActivityNameRelationships: String {
    case activityItems = "activityItems"
}

@objc
class _ActivityName: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Activity"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _ActivityName.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var i18nable: NSNumber?

    // func validateI18nable(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var name: String?

    // func validateName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var activityItems: NSSet

}

extension _ActivityName {

    func addActivityItems(objects: NSSet) {
        let mutable = self.activityItems.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.activityItems = mutable.copy() as NSSet
    }

    func removeActivityItems(objects: NSSet) {
        let mutable = self.activityItems.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.activityItems = mutable.copy() as NSSet
    }

    func addActivityItemsObject(value: ActivityItem!) {
        let mutable = self.activityItems.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.activityItems = mutable.copy() as NSSet
    }

    func removeActivityItemsObject(value: ActivityItem!) {
        let mutable = self.activityItems.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.activityItems = mutable.copy() as NSSet
    }

}
