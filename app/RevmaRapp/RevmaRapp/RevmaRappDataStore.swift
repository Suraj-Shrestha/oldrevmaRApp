//
//  RevmaRappDataStore.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 04/01/16.
//  Copyright © 2016 Norsk Regnesentral. All rights reserved.
//

import Foundation
import CoreData

class RevmaRappDataStore {

    private func createDummyPeriods() {
        for i in 1...3 {
            let period = ActivityPeriod(managedObjectContext: self.managedObjectContext)
            period.name = "Test Period \(i)"
            period.start = NSDate(timeIntervalSinceNow: -60.0 * 60.0 * 24.0 * 33.0 * Double(i))
            // I'll be setting up the end date soon (in the dummy objects)!
        }
    }

    private func createDummyObjects() {

        createDummyPeriods()

        let periodFetchRequest = NSFetchRequest(entityName: ActivityPeriod.entityName())
        do {
            let periodResults = try self.managedObjectContext.executeFetchRequest(periodFetchRequest)
            let periods = periodResults as! [ActivityPeriod]
            let fetchRequest = NSFetchRequest(entityName: ActivityName.entityName())
            do {
                let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
                let activityNames = results as! [ActivityName]
                let DaysInPeriod = 3
                let RecsInDay = 14
                let RecordCount = RecsInDay * DaysInPeriod * periods.count
                let ActivityDuration = [15, 30, 45, 60, 90]

                var randomIndex = 0
                var rando = [UInt8](count:7 * RecordCount, repeatedValue: 0)
                SecRandomCopyBytes(kSecRandomDefault, rando.count, UnsafeMutablePointer<UInt8>(rando))
                for period in periods {
                    var date1 = period.start!
                    for day in 1...DaysInPeriod {
                        date1 = period.start!.dateByAddingTimeInterval(60 * 60 * 24 * Double(day) - 1)
                        for _ in 1...RecsInDay {
                            let activity = ActivityItem(managedObjectContext: self.managedObjectContext)
                            activity.period = period
                            activity.activity = activityNames[Int(bitPattern: UInt(rando[randomIndex++])) % activityNames.count]
                            activity.time_start = date1
                            activity.duration = ActivityDuration[Int(bitPattern: UInt(rando[randomIndex++])) % ActivityDuration.count]
                            activity.pain = NSNumber(double: Double(Int(bitPattern: UInt(rando[randomIndex++]))) / 255.0)
                            activity.mastery = NSNumber(double: Double(Int(bitPattern: UInt(rando[randomIndex++]))) / 255.0)
                            activity.duty = NSNumber(double: Double(Int(bitPattern: UInt(rando[randomIndex++]))) / 255.0)
                            activity.energy = NSNumber(double: Double(Int(bitPattern: UInt(rando[randomIndex++]))) / 255.0)
                            activity.importance = NSNumber(double: Double(Int(bitPattern: UInt(rando[randomIndex++]))) / 255.0)
                            date1 = date1.dateByAddingTimeInterval(60 * activity.duration!.doubleValue)
                        }
                    }
                    period.stop = date1
                }
            } catch let error as NSError {
                print("Unresolved error \(error.localizedDescription), \(error.userInfo)\n Attempting to get activity names")

            }
        } catch let error as NSError {
            print("Unresolved error \(error.localizedDescription), \(error.userInfo)\n Attempting to get activity names")
        }
    }

    func createObjects() {
        let fetchRequest = NSFetchRequest(entityName: ActivityName.entityName())

        do {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            if results.count > 0 {
                return
            }
        } catch let error as NSError {
            print("Unresolved error \(error.localizedDescription), \(error.userInfo)\nMy query was \(fetchRequest)")
        }

        // ActivityNameKeys
        let activityNameKeys = ["ActivityHygiene", "ActivityDressing", "ActivityEating", "ActivityMealPrep", "ActivityShopping",
            "ActivityHousework", "ActivityYardwork", "ActvityHomeRepair", "ActivityLabor", "ActivityEducation",
            "ActivityFamilyTime", "ActivityCare", "ActivityTransport", "ActivityTV", "ActivityListeningMusic",
            "ActivityDeskWork", "ActivityReading", "ActivityTelephone", "ActivityPC", "ActivityNature",
            "ActivitySocial", "ActivityCulture", "ActivityTrainingLow", "ActivityTrainingHigh", "ActivityRest",
            "ActivitySleep"]


        // Do I like repeating myself? I guess I do, just to make sure that these items are picked up in future translations
        _ = [
            NSLocalizedString("ActivityHygiene", comment:"ActivityHygiene"),
            NSLocalizedString("ActivityDressing", comment:"ActivityDressing"),
            NSLocalizedString("ActivityEating", comment:"ActivityEating"),
            NSLocalizedString("ActivityMealPrep", comment:"ActivityMealPrep"),
            NSLocalizedString("ActivityShopping", comment:"ActivityShopping"),
            NSLocalizedString("ActivityHousework", comment:"ActivityHousework"),
            NSLocalizedString("ActivityYardwork", comment:"ActivityYardwork"),
            NSLocalizedString("ActvityHomeRepair", comment:"ActvityHomeRepair"),
            NSLocalizedString("ActivityLabor", comment:"ActivityLabor"),
            NSLocalizedString("ActivityEducation", comment:"ActivityEducation"),
            NSLocalizedString("ActivityFamilyTime", comment:"ActivityFamilyTime"),
            NSLocalizedString("ActivityCare", comment:"ActivityCare"),
            NSLocalizedString("ActivityTransport", comment:"ActivityTransport"),
            NSLocalizedString("ActivityTV", comment:"ActivityTV"),
            NSLocalizedString("ActivityListeningMusic", comment:"ActivityListeningMusic"),
            NSLocalizedString("ActivityDeskWork", comment:"ActivityDeskWork"),
            NSLocalizedString("ActivityReading", comment:"ActivityReading"),
            NSLocalizedString("ActivityTelephone", comment:"ActivityTelephone"),
            NSLocalizedString("ActivityPC", comment:"ActivityPC"),
            NSLocalizedString("ActivityNature", comment:"ActivityNature"),
            NSLocalizedString("ActivitySocial", comment:"ActivitySocial"),
            NSLocalizedString("ActivityCulture", comment:"ActivityCulture"),
            NSLocalizedString("ActivityTrainingLow", comment:"ActivityTrainingLow"),
            NSLocalizedString("ActivityTrainingHigh", comment:"ActivityTrainingHigh"),
            NSLocalizedString("ActivityRest", comment:"ActivityRest"),
            NSLocalizedString("ActivitySleep", comment:"ActivitySleep")
        ]

        for name in activityNameKeys {
            let catalogEntry = ActivityName(managedObjectContext: self.managedObjectContext)
            catalogEntry.name = name
            catalogEntry.i18nable = true
        }

        //createDummyObjects()

        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            print("Saving records went wrong \(error), \(error.userInfo)")
        }
    }

    lazy var managedObjectContext: NSManagedObjectContext = {
        let modelURL = NSBundle.mainBundle().URLForResource("RevmaRapp", withExtension: "momd")
        let mom = NSManagedObjectModel(contentsOfURL: modelURL!)
        ZAssert(mom != nil, "Error initializing mom from: \(modelURL)")

        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom!)

        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let storeURL = (urls[urls.endIndex-1]).URLByAppendingPathComponent("RevmaRapp.sqlite")

        var error: NSError?

        var store: NSPersistentStore?
        do {
            store = try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        } catch var error as NSError {
            store = nil
            print("Failed to load store")
        } catch {
            fatalError()
        }
        if (store == nil) {

        }


        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = psc

        return managedObjectContext
    }()

    func fetchActivitiesForPeriod(period:ActivityPeriod) -> [Int: [ActivityItem]] {
        var activitiesByDays = [Int: [ActivityItem]]()

        let fetchRequest = NSFetchRequest(entityName: ActivityItem.entityName())
        fetchRequest.predicate = NSPredicate(format: "\(ActivityItemRelationships.period.rawValue) == %@", argumentArray: [period])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: ActivityItemAttributes.time_start.rawValue, ascending: false)]
        var error: NSError?
        do {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            let activities = results as! [ActivityItem]
            if !activities.isEmpty {
                let calendar = NSCalendar.currentCalendar()
                var sectionNum = 0
                var currentDay:Int
                if #available(iOS 8.0, *) {
                    currentDay = calendar.component(NSCalendarUnit.Day, fromDate: activities[0].time_start!)
                } else {
                    let components = calendar.components(NSCalendarUnit.Day, fromDate: activities[0].time_start!)
                    currentDay = components.day
                }
                var activitiesInDay:[ActivityItem] = []
                for activity in activities {
                    let day:Int
                    if #available(iOS 8.0, *) {
                        day = calendar.component(NSCalendarUnit.Day, fromDate: activity.time_start!)
                    } else {
                        let components = calendar.components(NSCalendarUnit.Day, fromDate: activity.time_start!)
                        day = components.day
                    }
                    if day != currentDay {
                        activitiesByDays[sectionNum] = activitiesInDay
                        sectionNum = sectionNum + 1
                        currentDay = day
                        activitiesInDay = []
                    }
                    activitiesInDay.append(activity)
                }
                // The last set of activities wasn't added, so do that here.
                activitiesByDays[sectionNum] = activitiesInDay
            }
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Attempting to get activity names")
        }
        return activitiesByDays
    }

    func overlapDatesWithPeriod(startDate: NSDate, endDate: NSDate) -> Bool {
        let fetchRequest = NSFetchRequest(entityName: ActivityPeriod.entityName())
        fetchRequest.predicate = NSPredicate(format: "(%@ <= stop) AND (start <= %@)", startDate, endDate)
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
            return results.count != 0
        } catch let error as NSError {
            print("Unresolved error \(error.localizedDescription), \(error.userInfo)\n Attempting to get activity names")
        }
        return false
    }

    func fetchPeriods() -> [ActivityPeriod] {
        // Probably need to page this by date at some point as well, for now get me everything
        var periods: [ActivityPeriod] = []
        let fetchRequest = NSFetchRequest(entityName: ActivityPeriod.entityName())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: ActivityPeriodAttributes.start.rawValue, ascending: false)]
        do {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            periods = results as! [ActivityPeriod]
        } catch let error as NSError {
            print("Unresolved error \(error.localizedDescription), \(error.userInfo)\n Attempting to get activity names")
        }
        return periods
    }

    func fetchActivityNames() -> [ActivityName] {
        var activityNames: [ActivityName] = []
        let fetchRequest = NSFetchRequest(entityName: ActivityName.entityName())
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
            activityNames = results as! [ActivityName]
            activityNames.sortInPlace({ $0.name! < $1.name! })
        } catch let error as NSError {
            print("Unresolved error \(error.localizedDescription), \(error.userInfo)\n Attempting to get activity names")
        }
        return activityNames
    }

    func createPeriod(periodName: String) -> ActivityPeriod {
        let period = ActivityPeriod(managedObjectContext: managedObjectContext)
        period.name = periodName
        return period
    }

    func createEmptyActivity() -> ActivityItem {
        return ActivityItem(managedObjectContext: managedObjectContext)
    }

    func createActivity(name: String) -> ActivityName {
        let newActivityName = ActivityName(managedObjectContext: managedObjectContext)
        newActivityName.name = name
        return newActivityName
    }

    func saveContext() {

        let moc = self.managedObjectContext
        if !moc.hasChanges {
            return
        }
        do {
            try moc.save()
            return
        } catch let error as NSError {
            print("Error saving context: \(error.localizedDescription)\n\(error.userInfo)")
        }

        abort()
    }
}