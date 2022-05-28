//
//  PersistanceProvider.swift
//  XKCDZ
//
//  Created by Adin on 4/15/22.
//

import Foundation
import CoreData

final class PersistenceProvider {
    let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext { persistentContainer.viewContext }
    
    static let `default`: PersistenceProvider = PersistenceProvider()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "xkcd_metadata")
        
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Error loading persistence stores: \(error.localizedDescription)")
            }
        }
    }
}
