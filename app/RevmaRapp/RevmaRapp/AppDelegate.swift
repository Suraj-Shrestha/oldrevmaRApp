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
        fetchRequest.predicate = NSPredicate(format: "lang == %@", argumentArray: [currLang])
        
        var error: NSError?

        if let results = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) {
            if results.count > 0 {
                return
            }
        } else {
            ZAssert(error != nil, "Unresolved error \(error?.localizedDescription), \(error?.userInfo)\nMy query was \(fetchRequest)")
        }
        
        var activityNames: [String]
        // Put in some things for this language
        switch (currLang) {
        case "nb":
            activityNames = [ "Husarbeid", "Hagearbeid", "Transport", "Personlig hygiene",
                                 "Av og påkledning", "Måltider", "Stillesittende arbied",
                                 "Møter", "Forelesning", "Fysisk arbeid", "Telefonsamtaler", "Lesing",
                                 "Familieomsorg", "Samliv", "Omgang med venner", "Kulturliv", "Hobbyaktiviteter",
                                 "Skermtid (tv/PC/nettbrett)", "Trene", "Hvile", "Lytte på musikk/radio"]
        case "en":
            fallthrough
        default: // Default is English (for now)
            activityNames = [ "Housework", "Yardwork", "Transport", "Personal hygiene",
                "dressing and undressing", "Meals", "Desk work",
                "Meetings", "Lectures", "Physical labor", "Telephone conversation", "Reading",
                "Family care", "Intimate time", "Spending time with friends", "Kultural activity", "Hobby",
                "Screen time (tv/PC/tablet)", "Training", "Resting", "Listening to music/radio"]
            
        }
        
        for name in activityNames {
            let catalogEntry = ActivityName(managedObjectContext: self.managedObjectContext)
            catalogEntry.name = name
            catalogEntry.lang = currLang
        }
        

        self.managedObjectContext.save(&error)
        
        ZAssert(error != nil, "Saving records went wrong \(error), \(error?.userInfo)")
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

