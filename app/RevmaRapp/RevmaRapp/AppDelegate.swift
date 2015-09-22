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

    let CompletedFirstTimeKey = "CompletedFirstTime"
    var window: UIWindow?
    var imageCache: NSCache?
    
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

    private func createObjects() {
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
        
        createDummyObjects()

        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            print("Saving records went wrong \(error), \(error.userInfo)")
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Generate our list of initial activities
        createObjects()
        
        // OK, the activity table view gets a managed object context
        let tabController = self.window!.rootViewController as! UITabBarController
        let navigationController = tabController.viewControllers![0] as! UINavigationController
        let periodTableController = navigationController.topViewController as! ActivityPeriodTableViewController
        periodTableController.managedObjectContext = self.managedObjectContext
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
        let defaults = NSUserDefaults.standardUserDefaults()

        // first time run through? I will keep this in case, we need to do something special here.
        if defaults.boolForKey(CompletedFirstTimeKey) == false {
            defaults.setBool(true, forKey: CompletedFirstTimeKey)
            defaults.synchronize()
        }

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.skyeroad.Proto" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()


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

    func saveContext () {

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
    
    static func rgbComponentsFor(energy: Double, isGreen: Bool) -> [CGFloat] {
        let redBase = 0.20
        let greenBase = 0.25
        let energyBase = isGreen ? greenBase : redBase
        return rgbComponetsFor(isGreen ? 120 : 0, saturation: 0.5, lightness: 1.15 - energyBase - energy)
    }
    
    // Ugly name here, but keep it for now.
    static func rgbComponetsForActivity(activity: ActivityItem) -> [CGFloat] {
        return rgbComponentsFor(activity.adjustedEnergyValue, isGreen: activity.isGreen)
    }

    private static func rgbComponetsFor(hue: Int, saturation: Double, lightness: Double) -> [CGFloat] {
        let bar = fabs(2.0 * lightness - 1.0)
        let C = (1.0 - bar) * saturation
        let foo = abs(hue / 60 % 2 - 1)
        let X = C * (1.0 - Double(foo))
        let m = lightness - C / 2
        
        let mPrime = CGFloat(m)
        let CPrime = CGFloat(C) + mPrime
        let XPrime = CGFloat(X) + mPrime
        
        switch hue {
        case 0...59:
            return [CPrime, XPrime, mPrime]
        case 60...119:
            return [XPrime, CPrime, mPrime]
        case 120...179:
            return [mPrime, CPrime, XPrime]
        case 180...239:
            return [mPrime, XPrime, CPrime]
        case 240...299:
            return [XPrime, mPrime, CPrime]
        case 300...359:
            return [CPrime, mPrime, XPrime]
        default:
            return [0.0, 0.0, 0.0]
        }
    }
    
    static func squareForValues(size:CGFloat, components:[CGFloat]) -> UIImage {
        let SquareSize:CGFloat = size
        UIGraphicsBeginImageContext(CGSizeMake(SquareSize, SquareSize))
        let context = UIGraphicsGetCurrentContext()
        CGContextSetRGBFillColor(context, components[0], components[1], components[2], 1.0)
        CGContextFillRect(context, CGRectMake(SquareSize / 2 - size / 2, SquareSize / 2 - size / 2, size, size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func imageForActivity(activity:ActivityItem) -> UIImage {
        let size = activity.durationAsSize
        let components = AppDelegate.rgbComponetsForActivity(activity)

        let key  = "\(size);\(components[0]);\(components[1]);\(components[2])"
        if imageCache == nil {
            imageCache = NSCache()
        }
        if let cachedImage = imageCache!.objectForKey(key) as? UIImage {
            return cachedImage
        }

        let image = AppDelegate.squareForValues(size, components:components)
        // otherwise build it ourselves
        imageCache!.setObject(image, forKey: key)
        return image
    }
}

