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
        persistentContainer = NSPersistentContainer(name: "xkcdz")
        
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Error loading persistence stores: \(error.localizedDescription)")
            }
        }
    }
    
    @discardableResult
    func createComicMetadata(jsonComicMetadata: JsonComicMetadata) async -> SafeComicMetadata? {
        if let storedMetadata = await getComicMetadata(jsonComicMetadata.num) {
            // Avoid duplicates
            
            return storedMetadata
        }
        
        var result: SafeComicMetadata? = nil
        await context.perform { [unowned self] in
            let newComicMeta = ComicMetadata(context: context)
            
            newComicMeta.num        = Int32(jsonComicMetadata.num)
            newComicMeta.img        = jsonComicMetadata.img
            newComicMeta.safe_title = jsonComicMetadata.safe_title
            newComicMeta.alt        = jsonComicMetadata.alt
            newComicMeta.day        = jsonComicMetadata.day
            newComicMeta.month      = jsonComicMetadata.month
            newComicMeta.year       = jsonComicMetadata.year
            newComicMeta.title      = jsonComicMetadata.title
            newComicMeta.transcript = jsonComicMetadata.transcript
            newComicMeta.link       = jsonComicMetadata.link
            newComicMeta.news       = jsonComicMetadata.news
            
            try? context.save()
            
            // This should never fail here? :)
            result = try! newComicMeta.toSafeType()
        }
        
        return result
    }
    
    func getComicMetadata(_ comicNum: Int) async -> SafeComicMetadata? {
        let request: NSFetchRequest<ComicMetadata> = ComicMetadata.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %d", #keyPath(ComicMetadata.num), comicNum)
        
        var result: SafeComicMetadata? = nil
        await context.perform { [unowned self] in
            let fetchResult = try? context.fetch(request)
            
            if fetchResult != nil && !fetchResult!.isEmpty {
                result = try? fetchResult![0].toSafeType()
            }
        }
        
        return result
    }
    
    func getLatestStoredMetadata() async -> SafeComicMetadata? {
        let request: NSFetchRequest<ComicMetadata> = ComicMetadata.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ComicMetadata.num, ascending: false)
        ]
        
        var result: SafeComicMetadata? = nil
        await context.perform { [weak self] in
            guard let self = self
            else {
                return
            }
            
            let fetchResult = try? self.context.fetch(request)
            
            if fetchResult != nil && !fetchResult!.isEmpty {
                result = try? fetchResult![0].toSafeType()
            }
        }
        
        return result
    }
    
    func createComicImage(comicMetadata: SafeComicMetadata, data: Data) async -> Data {
        if let storedImageData = await getComicImageData(comicMetadata: comicMetadata) {
            // Avoid duplicates
            
            return storedImageData
        }
        
        await context.perform { [weak self] in
            guard let self = self
            else {
                return
            }
            
            let result: ComicImage = ComicImage(context: self.context)
        
            let metadataFetchRequest: NSFetchRequest<ComicMetadata> = ComicMetadata.fetchRequest()
            metadataFetchRequest.predicate = NSPredicate(format: "%K == %d", #keyPath(ComicMetadata.num), Int32(comicMetadata.num))
            
            let fetchResult = try? self.context.fetch(metadataFetchRequest)
            guard let fetchResult = fetchResult, !fetchResult.isEmpty
            else {
                return
            }
            
            let loadedMetadata = fetchResult[0]
            
            result.num = Int32(comicMetadata.num)
            result.data = data
            result.comicMetadata = loadedMetadata
            
            loadedMetadata.comicImage = result
        
            try? self.context.save()
        }
        
        return data
    }
    
    private func getComicImageData(_ comicNum: Int) async -> Data? {
        // This is private to avoid getting an image by number without having downloaded the image metadata
        
        let request: NSFetchRequest<ComicImage> = ComicImage.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %d", #keyPath(ComicImage.num), Int32(comicNum))
        
        var result: Data? = nil
        await context.perform { [weak self] in
            guard let self = self
            else {
                return
            }
            
            let fetchResult = try? self.context.fetch(request)
            
            if fetchResult != nil && !fetchResult!.isEmpty {
                result = fetchResult![0].data
            }
        }
        
        return result
    }
    
    func getComicImageData(comicMetadata: SafeComicMetadata) async -> Data? {
        return await getComicImageData(comicMetadata.num)
    }
}

enum SafeMapError: Error {
    case InvalidMapping
}

protocol ToSafeType {
    associatedtype SafeType
    func toSafeType() throws -> SafeType
}
