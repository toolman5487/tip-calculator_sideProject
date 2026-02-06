//
//  CoreDataStack.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Foundation
import CoreData

@MainActor
enum CoreDataStack {

    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TipCalculator")
        container.persistentStoreDescriptions.forEach { desc in
            desc.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            desc.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        }
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unresolved Core Data error: \(error)")
            }
        }
        return container
    }()

    static var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    @discardableResult
    static func saveContext() -> Bool {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return true }
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
}

