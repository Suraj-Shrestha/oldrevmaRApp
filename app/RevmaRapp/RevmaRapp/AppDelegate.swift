//
//  AppDelegate.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 06/11/14.
//  Copyright (c) 2014 Norsk Regnesentral. All rights reserved.
//

import UIKit
import CoreData


func ZAssert(@autoclosure condition: () -> Bool, _ message: String = "", file:
    String = __FILE__, line: Int = __LINE__) {
#if DEBUG
    if !condition() {
        println("assertion failet at \(file):\(line): \(message)")
        abort()
    }
#endif
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let RevmaRappTabIndexKey = "RevmaRappTabIndex"

    var window: UIWindow?
    
    func createDummyObjects() {

        let fetchRequest = NSFetchRequest(entityName: ActivityName.entityName())
        var error: NSError?
        if let results = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) {
            let activityNames = results as! [ActivityName]
            let RecordCount = 240
            let RecsInDay = 16
            var randomIndex = 0
            var rando = [UInt8](count:6 * RecordCount, repeatedValue: 0)
            SecRandomCopyBytes(kSecRandomDefault, rando.count, UnsafeMutablePointer<UInt8>(rando))
            var date1 = NSDate()
            
            for recIndex in 1...RecordCount {
                let activity = ActivityItem(managedObjectContext: self.managedObjectContext)
                activity.activity = activityNames[Int(bitPattern: UInt(rando[randomIndex++])) % activityNames.count]
                activity.time_start = date1
                activity.duration = 30
                activity.pain = NSNumber(double: Double(Int(bitPattern: UInt(rando[randomIndex++]))) / 255.0)
                activity.mastery = NSNumber(double: Double(Int(bitPattern: UInt(rando[randomIndex++]))) / 255.0)
                activity.duty = NSNumber(double: Double(Int(bitPattern: UInt(rando[randomIndex++]))) / 255.0)
                activity.energy = NSNumber(double: Double(Int(bitPattern: UInt(rando[randomIndex++]))) / 255.0)
                activity.importance = NSNumber(double: Double(Int(bitPattern: UInt(rando[randomIndex++]))) / 255.0)
                if recIndex % RecsInDay == 0 {
                    let daysBack = (recIndex / RecsInDay) + (30 * (recIndex / (3 * RecsInDay)))
                    date1 = NSDate(timeIntervalSinceNow: -60.0 * 60.0 * 24.0 * Double(daysBack))
                }
            }
            
        } else {
            println("Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Attempting to get activity names")
        }
    }

    func createObjects() {
        let currLang = NSLocale.preferredLanguages()[0] as! String;
        
        let fetchRequest = NSFetchRequest(entityName: ActivityName.entityName())
        
        var error: NSError?

        if let results = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) {
            if results.count > 0 {
                return
            }
        } else {
            ZAssert(!(error != nil), "Unresolved error \(error?.localizedDescription), \(error?.userInfo)\nMy query was \(fetchRequest)")
        }
        
        // ActivityNameKeys
        let activityNameKeys = ["ActivityHygiene", "ActivityDressing", "ActivityEating", "ActivityMealPrep", "ActivityShopping",
            "ActivityHousework", "ActivityYardwork", "ActvityHomeRepair", "ActivityLabor", "ActivityEducation",
            "ActivityFamilyTime", "ActivityCare", "ActivityTransport", "ActivityTV", "ActivityListeningMusic",
            "ActivityDeskWork", "ActivityReading", "ActivityTelephone", "ActivityPC", "ActivityNature",
            "ActivitySocial", "ActivityCulture", "ActivityTrainingLow", "ActivityTrainingHigh", "ActivityRest",
            "ActivitySleep"]
            
        
        // Do I like repeating myself? I guess I do, just to make sure that these items are picked up in future translations
        let activityNames = [
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
        
        createDummyObjects()

        self.managedObjectContext.save(&error)
        
        ZAssert(error == nil, "Saving records went wrong \(error), \(error?.userInfo)")
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Generate our list of initial activities
        createObjects()
        
        // OK, the activity table view gets a managed object context
        let tabController = self.window!.rootViewController as! UITabBarController
        let activityTableController = tabController.viewControllers![0].topViewController as! ActivityTableViewController
        activityTableController.managedObjectContext = self.managedObjectContext
        let defaults = NSUserDefaults.standardUserDefaults()
        tabController.selectedIndex = defaults.integerForKey(RevmaRappTabIndexKey)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        let tabController = self.window!.rootViewController as! UITabBarController
        let currentTabIndex = tabController.selectedIndex
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(currentTabIndex, forKey: RevmaRappTabIndexKey)
        defaults.synchronize()
        self.saveContext()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.skyeroad.Proto" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()


    lazy var managedObjectContext: NSManagedObjectContext = {
        let modelURL = NSBundle.mainBundle().URLForResource("RevmaRapp", withExtension: "momd")
        let mom = NSManagedObjectModel(contentsOfURL: modelURL!)
        ZAssert(mom != nil, "Error initializing mom from: \(modelURL)")
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom!)
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let storeURL = (urls[urls.endIndex-1]).URLByAppendingPathComponent("RevmaRapp.sqlite")
        
        var error: NSError?
        
        var store = psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error)
        if (store == nil) {
            println("Failed to load store")
        }
        ZAssert(store != nil, "Unresolved error \(error?.localizedDescription), \(error?.userInfo)\nAttempted to create store at \(storeURL)")
        
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = psc
        
        return managedObjectContext
    }()

    func saveContext () {
        var error: NSError?
        let moc = self.managedObjectContext
        if !moc.hasChanges {
            return
        }
        if moc.save(&error) {
            return
        }
        println("Error saving context: \(error?.localizedDescription)\n\(error?.userInfo)")
        abort()
    }


}

