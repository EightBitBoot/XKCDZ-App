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
    
    func getComicMetadata(for comicNum: Int) async throws -> ComicMetadata {
        let fetchRequest = StoredComicMetadata.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %d", #keyPath(StoredComicMetadata.comic_num), comicNum)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchLimit = 1
        
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
        fetchRequest.predicate = NSPredicate(format: "%K != 0", #keyPath(StoredComicMetadata.img_ratio))
        
        var result: [Int:Float] = [:]
        try context.performAndWait { [weak self] in
            guard let self = self
            else {
                throw PersistenceError.SelfHasBeenUnloaded
            }
            
            let fetchResult = try self.context.fetch(fetchRequest)
            
            fetchResult.forEach {
                result[Int($0.comic_num)] = $0.img_ratio
            }
        }
        
        return result
    }
}

enum PersistenceError: Error {
    case SelfHasBeenUnloaded
    case MetadataNotFound
    case MetadataWithComicNumAlreadyStored
}
