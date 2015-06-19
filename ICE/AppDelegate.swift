 //
 //  AppDelegate.swift
 //  ICE
 //
 //  Created by Felix Gruber on 25.03.15.
 //  Copyright (c) 2015 Felix Gruber. All rights reserved.
 //
 
 import UIKit
 import CoreData
 
 @UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let NOTIF_TIME_IN_SECONDS: Double = 5
    
    // MARK: - Core Data stack
    
    func application(application: UIApplication, openURL url: NSURL,
        sourceApplication: String?, annotation: AnyObject) -> Bool {
            return false
    }
    
    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes:
                [UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories: nil))
            return true
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "at.fhooe.mc.MOM4.Test" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ICE", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ICE.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        var temp:NSPersistentStore? = nil;
        do{
            temp = try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        }catch _{}
        if temp == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func save () {
        if let moc = self.managedObjectContext {
            if moc.hasChanges {
                do{
                    try moc.save()
                }catch _{
                    abort()
                }
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        makeNewNotif()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
    }
    
    func applicationWillTerminate(application: UIApplication) {
        makeNewNotif()
    }
    
    // notification stuff
    func makeNewNotif(){
        let localNotif = UILocalNotification()
        localNotif.alertTitle = "In Case of Emergency call"
        let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.at.fhooe.mc.MOM4.ICE")!
        /*
        let name = defaults.stringForKey("name")
        let bloodtype = defaults.stringForKey("bloodtype")
        let allergies = defaults.stringForKey("allergies")
        let medhist = defaults.stringForKey("medhist")
        */
        let numbers = defaults.stringArrayForKey("numbers")
        /*
        let numbersAsString = "\n".join(numbers!)
        let arr = ["Name:\n\(name as String!)", "Bloodtype:\n\(bloodtype as String!)", "Allergies:\n\(allergies as String!)", "Medical History:\n\(medhist as String!)", "Numbers:\n\(numbersAsString)"]
        */
        localNotif.alertBody = "\n".join(numbers!)
        localNotif.timeZone = NSTimeZone.defaultTimeZone()
        localNotif.fireDate = NSDate(timeIntervalSinceNow: NOTIF_TIME_IN_SECONDS)
        localNotif.category = "NOTIFCAT"
        localNotif.fireDate = NSDate(timeIntervalSinceNow: 30)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotif)
    }
 }