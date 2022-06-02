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
    
    static let shared: PersistenceProvider = PersistenceProvider()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "xkcd_metadata")
        
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Error loading persistence stores: \(error.localizedDescription)")
            }
        }
    }
    
    // This function needs to duplicate the entire closure because it has
    // to capture the result in performAndWait
    func getComicMetadata(for comicNum: Int) throws -> ComicMetadata {
        // A comicNum of 0 gets the latest metadata
        
        let fetchRequest = comicMetadataFetchRequest(comicNum)
        
        // Optional so it can be captured in closure
        // without initalization
        var result: ComicMetadata?
        try context.performAndWait { [weak self] in
            guard let self = self
            else {
                throw PersistenceError.SelfHasBeenUnloaded
            }
            
            let fetchResults = try self.context.fetch(fetchRequest)
            guard !fetchResults.isEmpty
            else {
                throw PersistenceError.MetadataNotFound
            }
            
            result = try fetchResults[0].toSafeType()
        }
        
        // This will only be reached if the closure completes
        // sucessfully
        return result!
    }
    
    func getComicMetadata(for comicNum: Int) async throws -> ComicMetadata {
        // A comicNum of 0 gets the latest metadata
        
        let fetchRequest = comicMetadataFetchRequest(comicNum)
        
        // Optional so it can be captured in closure
        // without initalization
        var result: ComicMetadata?
        try await context.perform { [weak self] in
            guard let self = self
            else {
                throw PersistenceError.SelfHasBeenUnloaded
            }
            
            let fetchResults = try self.context.fetch(fetchRequest)
            guard !fetchResults.isEmpty
            else {
                throw PersistenceError.MetadataNotFound
            }
            
            result = try fetchResults[0].toSafeType()
        }
        
        // This will only be reached if the closure completes
        // sucessfully
        return result!
    }
    
    func storeComicMetadata(new comicMetadata: ComicMetadata) async throws {
        let storedMetadata = try? await getComicMetadata(for: comicMetadata.comicNum)
        guard storedMetadata == nil
        else {
            throw PersistenceError.MetadataWithComicNumAlreadyStored
        }
        
        try await context.perform { [weak self] in
            guard let self = self
            else {
                throw PersistenceError.SelfHasBeenUnloaded
            }
            
            let _ = StoredComicMetadata.fromSafeType(context: self.context, copyOf: comicMetadata)
            try self.context.save()
        }
    }
    
    func getAllRatios() throws -> [Int:Float] {
        let fetchRequest = StoredComicMetadata.fetchRequest()
        fetchRequest.propertiesToFetch = ["comic_num", "img_ratio"]
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "%K != 0.0", #keyPath(StoredComicMetadata.img_ratio))
        
        var result: [Int:Float] = [:]
        try context.performAndWait { [weak self] in
            guard let self = self
            else {
                throw PersistenceError.SelfHasBeenUnloaded
            }
            
            let fetchResult = try self.context.fetch(fetchRequest)
            
            result = Dictionary(uniqueKeysWithValues: fetchResult.map {
                return (Int($0.comic_num), $0.img_ratio)
            })
        }
        
        return result
    }
    
    private func comicMetadataFetchRequest(_ comicNum: Int) -> NSFetchRequest<StoredComicMetadata> {
        let fetchRequest = StoredComicMetadata.fetchRequest()
        
        if comicNum == 0 {
            // Get the latest metadata
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: #keyPath(StoredComicMetadata.comic_num), ascending: false)
            ]
        }
        else {
            // Get a specifically numbered metadata
            fetchRequest.predicate = NSPredicate(format: "%K == %d", #keyPath(StoredComicMetadata.comic_num), comicNum)
        }
        // These are common to both scenarios
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchLimit = 1
        
        return fetchRequest
    }
}

enum PersistenceError: Error {
    case SelfHasBeenUnloaded
    case MetadataNotFound
    case MetadataWithComicNumAlreadyStored
}
