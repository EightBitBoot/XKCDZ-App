//
//  ComicStore.swift
//  XKCDZ
//
//  Created by Adin on 5/29/22.
//

import Foundation
import UIKit

// NOTE(Adin): Functions with "stored" in the name are synchronous functions
//             that don't fetch objects from the server if they are not found
//             in the persistent store

final class ComicStore {
    public static let shared = ComicStore()
    
    private init() {}
    
//    private var comicImageCache: NSCache<CacheKey, UIImage> = NSCache()
    
    func getComicMetadata(for comicNum: Int = 0) async -> ComicMetadata? {
        // A comicNum of 0 gets the latest metadata
        
        // First, check the persistent store
        let storedMetadata = try? await PersistenceProvider.shared.getComicMetadata(for: comicNum)
        if storedMetadata != nil {
            return storedMetadata
        }
        
        // Then, (if that fails) fetch the metadata from the server
        let fetchedMetadata = try? await ComicFetcher.shared.fetchComicMetadata(for: comicNum)
        if let fetchedMetadata = fetchedMetadata {
            try? await PersistenceProvider.shared.storeComicMetadata(new: fetchedMetadata)
            return fetchedMetadata
        }
        
        return nil
    }
    
    func getStoredComicMetadata(for comicNum: Int = 0) -> ComicMetadata? {
        // comicNum of 0 gets the latest stored metadata
        return try? PersistenceProvider.shared.getComicMetadata(for: comicNum)
    }
    
    func getComicImage(for comicNum: Int, ofSize imgSize: ComicImageSize = .Default) async -> UIImage? {
        let metadata = await getComicMetadata(for: comicNum)
        guard let metadata = metadata
        else {
            return nil
        }

        let imgRequest = ComicImageRequest(for: metadata, ofSize: imgSize)
        
//        // First check the cache
//        let cachedImage = comicImageCache.object(forKey: CacheKey(imgRequest))
//        if let cachedImage = cachedImage {
//            return cachedImage
//        }
        
        // Next, (if that fails) check the persistent store
        let storedImage = try? await ComicImageDatabase.shared.getComicImage(of: imgRequest)
        if let storedImage = storedImage {
            let newUIImage = UIImage(data: storedImage)
//            if let newUIImage = newUIImage {
//                comicImageCache.setObject(newUIImage, forKey: CacheKey(imgRequest))
//            }
            
            return newUIImage
        }
        
        // Finally, (if the first two fail) fetch the image from the server
        let fetchedImage = try? await ComicFetcher.shared.fetchComicImageData(for: imgRequest)
        if let fetchedImage = fetchedImage {
            try? await ComicImageDatabase.shared.storeComicImage(of: imgRequest, withContents: fetchedImage)
            
            let newUIImage = UIImage(data: fetchedImage)
            // TODO(Adin): Store the image ratio in the persistent store
//            if let newUIImage = newUIImage {
//                comicImageCache.setObject(newUIImage, forKey: CacheKey(imgRequest))
//            }
            
            return newUIImage
        }
        
        return nil
    }
    
    // Convenience function to get the largest comic image as some comics
    // don't have .Large (_2x) images
    func getLargestComicImage(for comicNum: Int) async -> UIImage? {
        if let largeImage = await getComicImage(for: comicNum, ofSize: .Large) {
            return largeImage
        }
        
        return await getComicImage(for: comicNum, ofSize: .Default)
    }
    
    // Passthrough function needed for the ComicCollectionViewLayout
    // This maintains ComicStore's role as the only public interface
    // to the model layer
    func getAllStoredRatios() -> [Int:Float] {
        return (try? PersistenceProvider.shared.getAllRatios()) ?? [:]
    }
    
    func refreshComicStore() async {
        if let latestStoredMetadata = getStoredComicMetadata() {
            // There is at least one comic's metadata in the persistent store
            if let latestMetadata = await getComicMetadata() {
                // Sucessfully fetched the latest metadata from the server
                for newComicNum in latestStoredMetadata.comicNum..<latestMetadata.comicNum {
                    // Get (and store) all comics' metadata from the latest stored
                    // to the latest
                    let _ = await getComicMetadata(for: newComicNum)
                }
            }
        }
        else {
            guard let latestMetadata = await getComicMetadata()
            else {
                // Failed to fetch the latest metadata from the server
                return
            }
            
            // Fetch (at most) 100 comics from the server (and add them to the persistent store)
            let oldestComicNum = max(latestMetadata.comicNum - 100, 1)
            for newComicNum in oldestComicNum..<latestMetadata.comicNum {
                let _ = await getComicMetadata(for: newComicNum)
            }
        }
    }
}

private class CacheKey: NSObject {
    let imgRequest: ComicImageRequest
    
    init(_ imgRequest: ComicImageRequest) {
        self.imgRequest = imgRequest
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CacheKey
        else {
            return false
        }
        
        return imgRequest.comicMetadata.comicNum == other.imgRequest.comicMetadata.comicNum &&
               imgRequest.imgSize == other.imgRequest.imgSize
    }
}
