//
//  Model.swift
//  Interactive Historical Maps
//
//  Created by Goki on 12/1/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import Foundation
import CoreData

import MapKit

class Model {
    
    static let shared = Model()
    
    var maps : [Map]
    var date : HistoricalDate
    var context : NSManagedObjectContext { return persistentContainer.viewContext }
    
    private init() {
        maps = []
        date = HistoricalDate.init(month: 0, year: 0)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Map")
        do {
            maps = try persistentContainer.viewContext.fetch(request) as! [Map]
            
            if maps.count < 3 {
                maps.append(Map(context: persistentContainer.viewContext))
                maps.append(Map(context: persistentContainer.viewContext))
                maps.append(Map(context: persistentContainer.viewContext))
                
                maps[0].name = "Ibn Battuta's Rihla"
                maps[1].name = "The Origins of the Golden Arches"
                maps[2].name = "Cities"
                
                maps[0].author = "Jyoti Balachandran"
                maps[1].author = "Ronald McDonald"
                maps[2].author = "Gokulan Gnanendran"
                
                maps[0].set(start: HistoricalDate(month: 8, year: 1332))
                maps[1].set(start: HistoricalDate(month: 3, year: 1955))
                maps[2].set(start: HistoricalDate(month: 0, year: 1200))
                
                maps[0].set(end: HistoricalDate(month: 9, year: 1346))
                maps[1].set(end: HistoricalDate(month: 11, year: 2018))
                maps[2].set(end: HistoricalDate(month: 11, year: 2018))
            }
            
        } catch {
            print("Error")
            maps = []
        }
        
        self.saveContext()
    }
    
    func addMap() -> Int {
        maps.append(Map(context: persistentContainer.viewContext))
        return maps.count-1
    }
    
    func delete(_ map: Map) {
        persistentContainer.viewContext.delete(map)
    }
    
    var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
