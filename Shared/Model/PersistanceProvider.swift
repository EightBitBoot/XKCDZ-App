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
    
    init() {
        persistentContainer = NSPersistentContainer(name: "xkcdz")
        
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Error loading persistence stores: \(error.localizedDescription)")
            }
        }
    }
    
    @discardableResult
    func createComicMetadata(jsonComicMetadata: JsonComicMetadata) -> ComicMetadata {
        if let storedMetadata = getComicMetadata(jsonComicMetadata.num) {
            // Avoid duplicates
            
            return storedMetadata
        }
        
        let result = ComicMetadata(context: context)
        
        result.num        = Int32(jsonComicMetadata.num)
        result.img        = jsonComicMetadata.img
        result.safe_title = jsonComicMetadata.safe_title
        result.alt        = jsonComicMetadata.alt
        result.day        = jsonComicMetadata.day
        result.month      = jsonComicMetadata.month
        result.year       = jsonComicMetadata.year
        result.title      = jsonComicMetadata.title
        result.transcript = jsonComicMetadata.transcript
        result.link       = jsonComicMetadata.link
        result.news       = jsonComicMetadata.news
        
        try? context.save()
        return result
    }
    
    func getComicMetadata(_ comicNum: Int) -> ComicMetadata? {
        let request: NSFetchRequest<ComicMetadata> = ComicMetadata.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %d", #keyPath(ComicMetadata.num), comicNum)
        let fetchResult = try? context.fetch(request)
        
        if fetchResult != nil && !fetchResult!.isEmpty {
            return fetchResult![0]
        }
        
        return nil
    }
    
    func getLatestStoredMetadata() -> ComicMetadata? {
        let request: NSFetchRequest<ComicMetadata> = ComicMetadata.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ComicMetadata.num, ascending: false)
        ]
        let fetchResult = try? context.fetch(request)
        
        if fetchResult != nil && !fetchResult!.isEmpty {
            return fetchResult![0]
        }
        
        return nil
    }
    
    func createComicImage(comicMetadata: ComicMetadata, data: Data) -> ComicImage {
        if let storedImage = getComicImage(comicMetadata: comicMetadata) {
            // Avoid duplicates
            
            return storedImage
        }
        
        let result: ComicImage = ComicImage(context: context)
        
        result.num = comicMetadata.num
        result.data = data
        result.comicMetadata = comicMetadata
        
        comicMetadata.comicImage = result
        
        try? context.save()
        
        return result
    }
    
    private func getComicImage(_ comicNum: Int) -> ComicImage? {
        // This is private to avoid getting an image by number without having downloaded the image metadata
        
        let request: NSFetchRequest<ComicImage> = ComicImage.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %d", #keyPath(ComicImage.num), Int32(comicNum))
        let fetchResult = try? context.fetch(request)
        
        if fetchResult != nil && !fetchResult!.isEmpty {
            return fetchResult![0]
        }
        
        return nil
    }
    
    func getComicImage(comicMetadata: ComicMetadata) -> ComicImage? {
        return getComicImage(Int(comicMetadata.num))
    }
}
