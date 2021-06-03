//
//  AppDelegate.swift
//  CourseTracker
//
//  Created by Jim on 07/05/2021.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if let poppinsRegular = UIFont(name: "Poppins Regular", size: 17) {
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: poppinsRegular], for: .normal)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: poppinsRegular], for: .highlighted)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: poppinsRegular], for: .disabled)
        }
        
        return true
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

