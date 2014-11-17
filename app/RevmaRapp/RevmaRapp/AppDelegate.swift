//
//  AppDelegate.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 06/11/14.
//  Copyright (c) 2014 Norsk Regnesentral. All rights reserved.
//

import UIKit
import CoreData


let DEBUG = true

func ZAssert(test: Bool, message: String) {
    if (test) {
        return
    }
    
    println(message)
    
    if (!DEBUG) {
        return
    }
    
    var exception = NSException()
    exception.raise()
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func createObjects() {
        let currLang = NSLocale.preferredLanguages()[0] as String;
        
        // TODO: Make this read from a translation file
        
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
        let activityNameKeys = [ "ActivityHousework", "ActivityYardwork", "ActivityTransport", "ActivityHygiene", "ActivityDressing",
                                    "ActivityMeals", "ActivityDeskWork", "ActivityMeetings", "ActivityLectures", "ActivityPhysicalLabor",
                                    "ActivityTelephone", "ActivityReading", "ActivityFamilyCare", "ActivityIntimate", "ActivityFriends",
                                    "ActivityKultural", "ActivityHobby", "ActivityScreenTime", "ActivityTraining", "ActivityResting",
                                    "ActivityListeningMusic" ]
        
        // Do I like repeating myself? I guess I do, just to make sure that these items are picked up in future translations
        let activityNames = [
            NSLocalizedString("ActivityHousework", comment: "ActivityName"),
            NSLocalizedString("ActivityYardwork",  comment: "AcitivityName"),
            NSLocalizedString("ActivityTransport", comment: "AcitivityName"),
            NSLocalizedString("ActivityHygiene",  comment: "AcitivityName"),
            NSLocalizedString("ActivityDressing",  comment: "AcitivityName"),
            NSLocalizedString("ActivityMeals",  comment: "AcitivityName"),
            NSLocalizedString("ActivityDeskWork",  comment: "AcitivityName"),
            NSLocalizedString("ActivityMeetings",  comment: "AcitivityName"),
            NSLocalizedString("ActivityLectures",  comment: "AcitivityName"),
            NSLocalizedString("ActivityPhysicalLabor",  comment: "AcitivityName"),
            NSLocalizedString("ActivityTelephone",  comment: "AcitivityName"),
            NSLocalizedString("ActivityReading",  comment: "AcitivityName"),
            NSLocalizedString("ActivityFamilyCare",  comment: "AcitivityName"),
            NSLocalizedString("ActivityIntimate",  comment: "AcitivityName"),
            NSLocalizedString("ActivityFriends",  comment: "AcitivityName"),
            NSLocalizedString("ActivityKultural",  comment: "AcitivityName"),
            NSLocalizedString("ActivityHobby",  comment: "AcitivityName"),
            NSLocalizedString("ActivityScreenTime",  comment: "AcitivityName"),
            NSLocalizedString("ActivityTraining", comment: "AcitivityName"),
            NSLocalizedString("ActivityResting", comment: "AcitivityName"),
            NSLocalizedString("ActivityListeningMusic", comment: "AcitivityName"),
        ]


        
        for name in activityNameKeys {
            let catalogEntry = ActivityName(managedObjectContext: self.managedObjectContext)
            catalogEntry.name = name
            catalogEntry.i18nable = true
        }
        

        self.managedObjectContext.save(&error)
        
        ZAssert(!(error != nil), "Saving records went wrong \(error), \(error?.userInfo)")
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Generate our list of initial activities
        createObjects()
        
        // OK, the activity table view gets a managed object context
        let tabController = self.window!.rootViewController as UITabBarController
        let activityTableController = tabController.viewControllers![0].topViewController as ActivityTableViewController
        activityTableController.managedObjectContext = self.managedObjectContext
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
        return urls[urls.count-1] as NSURL
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

