//
//  PersistanceProvider.swift
//  XKCDZ
//
//  Created by Adin on 4/15/22.
//

import Foundation
import CoreData

enum StoreActionResult {
    case Sucess
    case Failure(StoreActionFailureReason)
    case AlreadyStored
}

enum StoreActionFailureReason {
    case ContextSaveFailed
    case StoreComicImageWithoutMetadata
}


final class PersistenceProvider {
    let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext { persistentContainer.viewContext }
    
    static let `default`: PersistenceProvider = PersistenceProvider()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "xkcdz")
        
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Error loading persistence stores: \(error.localizedDescription)")
            }
        }
    }
    
    @discardableResult
    func storeComicMetadata(comicMetadata: ComicMetadata) async -> StoreActionResult {
        if await getComicMetadata(comicMetadata.num) != nil {
            // Avoid duplicates
            return .AlreadyStored
        }
        
        var result: StoreActionResult = .Sucess
        await context.perform { [unowned self] in
            let newStoredComicMetadata = StoredComicMetadata(context: context)
            
            newStoredComicMetadata.num        = Int32(comicMetadata.num)
            newStoredComicMetadata.img        = comicMetadata.img
            newStoredComicMetadata.safe_title = comicMetadata.safe_title
            newStoredComicMetadata.alt        = comicMetadata.alt
            newStoredComicMetadata.date       = comicMetadata.date
            newStoredComicMetadata.title      = comicMetadata.title
            newStoredComicMetadata.transcript = comicMetadata.transcript
            newStoredComicMetadata.link       = comicMetadata.link
            newStoredComicMetadata.news       = comicMetadata.news
            
            if (try? context.save()) == nil {
                result = .Failure(.ContextSaveFailed)
            }
        }
        
        return result
    }
    
    func getComicMetadata(_ comicNum: Int) async -> ComicMetadata? {
        let request: NSFetchRequest<StoredComicMetadata> = StoredComicMetadata.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %d", #keyPath(StoredComicMetadata.num), comicNum)
        request.includesSubentities = false
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = false
        
        var result: ComicMetadata? = nil
        await context.perform { [weak self] in
            guard let self = self
            else {
                return
            }
            
            let fetchResult = try? self.context.fetch(request)
            
            guard let fetchResult = fetchResult,
                  !fetchResult.isEmpty
            else {
                return
            }
            
            result = try? fetchResult[0].toSafeType()
#if DEBUG
            if result == nil {
                // StoredComicMetadata.toSafeType() failed
                print("Failed to convert SavedComicMetadata number \(comicNum) to ComicMetadata via toSafeType()")
            }
#endif
        }
        
        return result
    }
    
    func getLatestStoredMetadata() async -> ComicMetadata? {
       return await Task {
                        getLatestStoredMetadataBlocking()
                    }
                    .value
        
    }
    
    func getLatestStoredMetadataBlocking() -> ComicMetadata? {
        let request: NSFetchRequest<StoredComicMetadata> = StoredComicMetadata.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \StoredComicMetadata.num, ascending: false)
        ]
        request.includesSubentities = false
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = false
        
        var result: ComicMetadata? = nil
        context.performAndWait { [weak self] in
            guard let self = self
            else {
                return
            }
            
            let fetchResult = try? self.context.fetch(request)
            
            guard let fetchResult = fetchResult,
                  !fetchResult.isEmpty
            else {
                return
            }
            
            result = try? fetchResult[0].toSafeType()
#if DEBUG
            if result == nil {
                // StoredComicMetadata.toSafeType() failed
                print("Failed to convert SavedComicMetadata number \(fetchResult[0].num) to ComicMetadata via toSafeType()")
            }
#endif
        }
        
        return result
    }
    
    func getImageRatio(_ comicNum: Int) async -> Float? {
        return await Task {
                        getImageRatioBlocking(comicNum)
                    }
                    .value
    }
    
    func getImageRatioBlocking(_ comicNum: Int) -> Float? {
        let request = StoredComicImage.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %d", #keyPath(StoredComicMetadata.num), comicNum)
        request.includesSubentities = false
        request.fetchLimit = 1
        request.propertiesToFetch = ["ratio"]
        
        var result: Float? = nil
        context.performAndWait { [weak self] in
            guard let self = self
            else {
                return
            }
            
            let fetchResult = try? self.context.fetch(request)
            
            guard let fetchResult = fetchResult,
                  !fetchResult.isEmpty
            else {
                return
            }
            
            result = fetchResult[0].ratio
        }
        
        return result
    }
    
    func getAllImageRatiosBlocking() -> [Int:Float] {
        let request = StoredComicImage.fetchRequest()
        request.includesSubentities = false
        request.returnsObjectsAsFaults = false
        request.propertiesToFetch = ["num", "ratio"]
        
        var result: [Int:Float] = [:]
        context.performAndWait { [weak self] in
            guard let self = self
            else {
                return
            }
            
            let fetchResult = try? self.context.fetch(request)
            guard let fetchResult = fetchResult
            else {
                return
            }
            
            fetchResult.forEach { comicImage in
                result[Int(comicImage.num)] = comicImage.ratio
            }
        }
        
        return result
    }
    
    @discardableResult
    func storeComicImage(comicMetadata: ComicMetadata, comicImage: ComicImage) async -> StoreActionResult {
        if await getComicImageData(comicMetadata: comicMetadata) != nil{
            // Avoid duplicates
            return .AlreadyStored
        }

        var result: StoreActionResult = .Sucess
        await context.perform { [weak self] in
            guard let self = self
            else {
                return
            }
            
            let metadataFetchRequest: NSFetchRequest<StoredComicMetadata> = StoredComicMetadata.fetchRequest()
            metadataFetchRequest.predicate = NSPredicate(format: "%K == %d", #keyPath(StoredComicMetadata.num), Int32(comicMetadata.num))
            metadataFetchRequest.includesSubentities = false
            metadataFetchRequest.fetchLimit = 1
            
            let fetchResult = try? self.context.fetch(metadataFetchRequest)
            guard let fetchResult = fetchResult,
                  !fetchResult.isEmpty
            else {
                result = .Failure(.StoreComicImageWithoutMetadata)
                return
            }
            
            let fetchedStoredComicMetadata = fetchResult[0]
            
            let newStoredComicImage: StoredComicImage = StoredComicImage(context: self.context)
            newStoredComicImage.num = Int32(comicMetadata.num)
            newStoredComicImage.data = comicImage.data
            newStoredComicImage.ratio = comicImage.ratio
            newStoredComicImage.comicMetadata = fetchedStoredComicMetadata
            
            fetchedStoredComicMetadata.comicImage = newStoredComicImage
        
            if (try? self.context.save()) == nil {
                result = .Failure(.ContextSaveFailed)
            }
        }
        
        return result
    }
    
    private func getComicImageData(_ comicNum: Int) async -> ComicImage? {
        // This is private to strongly discourage getting a comic's image without having downloaded the image metadata first
        
        let request: NSFetchRequest<StoredComicImage> = StoredComicImage.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %d", #keyPath(StoredComicImage.num), Int32(comicNum))
        request.includesSubentities = false
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = false
        
        var result: ComicImage? = nil
        await context.perform { [weak self] in
            guard let self = self
            else {
                return
            }
            
            let fetchResult = try? self.context.fetch(request)
            
            if fetchResult != nil && !fetchResult!.isEmpty {
                result = try? fetchResult![0].toSafeType()
#if DEBUG
                // StoredComicMetadata.toSafeType() failed
                if result == nil {
                    print("Failed to convert SavedComicImage number \(comicNum) to ComicImage via toSafeType()")
                }
#endif
            }
        }
        
        return result
    }
    
    func getComicImageData(comicMetadata: ComicMetadata) async -> ComicImage? {
        return await getComicImageData(comicMetadata.num)
    }
}
