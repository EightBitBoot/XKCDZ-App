//
//  ComicStore.swift
//  XKCDZ
//
//  Created by Adin on 4/13/22.
//

import Foundation
import SwiftUI

enum FileFormat: String {
    case JPEG = ".jpg"
    case PNG = ".png"
}

class CacheKey: NSObject {
    let num: Int
    
    init(num: Int) {
        self.num = num
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CacheKey
        else {
            return false
        }
        
        return num == other.num
    }
    
    override var hash: Int {
        num.hashValue
    }
}

class CacheSafeComicMetadata {
    let comicMetadata: SafeComicMetadata
    
    init(comicMetadata: SafeComicMetadata) {
        self.comicMetadata = comicMetadata
    }
}

class CacheImage {
    let image: Image
    
    init(image: Image) {
        self.image = image
    }
}

class ComicStore {
    private static let metadataCache: NSCache<CacheKey, CacheSafeComicMetadata> = NSCache()
    private static let imageCache: NSCache<CacheKey, CacheImage> = NSCache()
    
    static func getMetadata(_ comicNum: Int) async -> SafeComicMetadata? {
        if let cachedMetadata = metadataCache.object(forKey: CacheKey(num: comicNum))?.comicMetadata {
            return cachedMetadata
        }
        
        if let storedMetadata = await PersistenceProvider.default.getComicMetadata(comicNum) {
            metadataCache.setObject(CacheSafeComicMetadata(comicMetadata: storedMetadata), forKey: CacheKey(num: comicNum))
            return storedMetadata
        }
        
        // TODO(Adin): Error printing?
        guard let jsonMetadata = try? await ComicLoader.getComicMetadata(comicNum: comicNum)
        else {
            // Error fetching comic metadata
            return nil
        }
        
        let createdMetadata: SafeComicMetadata? = await PersistenceProvider.default.createComicMetadata(jsonComicMetadata: jsonMetadata)
        
        if let createdMetadata = createdMetadata {
            metadataCache.setObject(CacheSafeComicMetadata(comicMetadata: createdMetadata), forKey: CacheKey(num: comicNum))
        }
        
        return createdMetadata
    }
    
    static func getLatestStoredMetadata() async -> SafeComicMetadata? {
        return await PersistenceProvider.default.getLatestStoredMetadata()
    }
    
    static func getImageData(_ comicNum: Int) async -> Image? {
        if let cachedImage = imageCache.object(forKey: CacheKey(num: comicNum)) {
            return cachedImage.image
        }
        
        guard let comicMetadata = await getMetadata(comicNum)
        else {
            // Stored metadata doesn't exist and there was an error fetching it from the server
            return nil
        }
        
        if let storedImageData = await PersistenceProvider.default.getComicImageData(comicMetadata: comicMetadata) {
            // TODO(Adin): Check for failed UIImage creation
            let image: Image = Image(uiImage: UIImage(data: storedImageData)!)
            imageCache.setObject(CacheImage(image: image), forKey: CacheKey(num: comicNum))
            return image
        }
        
        guard let fetchedImage = try? await ComicLoader.getComicImageData(imgAddress: comicMetadata.img)
        else {
            // Error fetching comic image data
            return nil
        }
        
        let createdImageData: Data? = await PersistenceProvider.default.createComicImage(comicMetadata: comicMetadata, data: fetchedImage)
        
        if let createdImageData = createdImageData {
            // TODO(Adin): Check for failed UIImage creation
            let createdImage = Image(uiImage: UIImage(data: createdImageData)!)
            imageCache.setObject(CacheImage(image: createdImage), forKey: CacheKey(num: comicNum))
            return createdImage
        }
        
        return nil
    }
    
    static func refreshComicStore() async {
        guard let latestMetadata = try? await ComicLoader.getComicMetadata()
        else {
            // TODO(Adin): This doesn't need to be fatal
            fatalError("Error refreshing comic store from server")
        }
        
        let baseComicNum: Int
        if let latestStoredMetadata = await PersistenceProvider.default.getLatestStoredMetadata() {
            baseComicNum = Int(latestStoredMetadata.num)
        }
        else {
            // Loading 100 comics is arbitrary and can be changed later if needed
            baseComicNum = latestMetadata.num - 100 >= 1 ? Int(latestMetadata.num) - 100 : 1
        }
        
        // .reversed() to load the comics newest -> oldest
        for comicNum in (baseComicNum...Int(latestMetadata.num)).reversed() {
            if let jsonMetadata = try? await ComicLoader.getComicMetadata(comicNum: comicNum) {
                await PersistenceProvider.default.createComicMetadata(jsonComicMetadata: jsonMetadata)
            }
        }
    }
}
