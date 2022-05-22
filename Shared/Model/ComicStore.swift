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

class CacheComicMetadata {
    let comicMetadata: ComicMetadata
    
    init(comicMetadata: ComicMetadata) {
        self.comicMetadata = comicMetadata
    }
}

class CacheComicImage {
    let image: Image
    let ratio: Float
    
    init(image: Image, ratio: Float) {
        self.image = image
        self.ratio = ratio
    }
}

class ComicStore {
    private static let metadataCache: NSCache<CacheKey, CacheComicMetadata> = NSCache()
    private static let imageCache: NSCache<CacheKey, CacheComicImage> = NSCache()
    
    static func getMetadata(_ comicNum: Int) async -> ComicMetadata? {
        if let cachedMetadata = metadataCache.object(forKey: CacheKey(num: comicNum))?.comicMetadata {
            return cachedMetadata
        }
        
        if let storedMetadata = await PersistenceProvider.default.getComicMetadata(comicNum) {
            metadataCache.setObject(CacheComicMetadata(comicMetadata: storedMetadata), forKey: CacheKey(num: comicNum))
            return storedMetadata
        }
        
        // TODO(Adin): Error printing?
        guard let fetchedMetadata = try? await ComicLoader.getComicMetadata(comicNum: comicNum)
        else {
            // Error fetching comic metadata
            return nil
        }
        
        await PersistenceProvider.default.storeComicMetadata(comicMetadata: fetchedMetadata)
        
        metadataCache.setObject(CacheComicMetadata(comicMetadata: fetchedMetadata), forKey: CacheKey(num: comicNum))
        
        return fetchedMetadata
    }
    
    static func getLatestStoredMetadata() async -> ComicMetadata? {
        return await PersistenceProvider.default.getLatestStoredMetadata()
    }
    
    static func getLatestStoredMetadataBlocking() -> ComicMetadata? {
        return PersistenceProvider.default.getLatestStoredMetadataBlocking()
    }
    
    static func getComicImage(_ comicNum: Int) async -> Image? {
        if let cachedImage = imageCache.object(forKey: CacheKey(num: comicNum)) {
            return cachedImage.image
        }
        
        guard let comicMetadata = await getMetadata(comicNum)
        else {
            // Stored metadata doesn't exist and there was an error fetching it from the server
            return nil
        }
        
        if let storedImage = await PersistenceProvider.default.getComicImageData(comicMetadata: comicMetadata) {
            // TODO(Adin): Check for failed UIImage creation
            let image: Image = Image(uiImage: UIImage(data: storedImage.data)!)
            imageCache.setObject(CacheComicImage(image: image, ratio: storedImage.ratio), forKey: CacheKey(num: comicNum))
            return image
        }
        
        guard let fetchedImageData = try? await ComicLoader.getComicImageData(imgAddress: comicMetadata.img)
        else {
            // Error fetching comic image data
            return nil
        }
        
        // TODO(Adin): Check for error creating UIImage (createdUIImage == nil)
        let newUIKitImage: UIImage = UIImage(data: fetchedImageData)!
        let ratio: CGFloat = (newUIKitImage.size.height * newUIKitImage.scale) / (newUIKitImage.size.width * newUIKitImage.scale)
        let createdComicImage = ComicImage(num: comicNum, data: fetchedImageData, ratio: Float(ratio))
        
        print("\(await PersistenceProvider.default.storeComicImage(comicMetadata: comicMetadata, comicImage: createdComicImage))")
        
        let newSwiftUIImage = Image(uiImage: newUIKitImage)
        imageCache.setObject(CacheComicImage(image: newSwiftUIImage, ratio: Float(ratio)), forKey: CacheKey(num: comicNum))
        return newSwiftUIImage
    }
    
    static func getImageRatio(_ comicNum: Int) async -> Float? {
        return await PersistenceProvider.default.getImageRatio(comicNum)
    }
    
    static func getImageRatioBlocking(_ comicNum: Int) -> Float? {
        return PersistenceProvider.default.getImageRatioBlocking(comicNum)
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
            if let fetchedMetadata = try? await ComicLoader.getComicMetadata(comicNum: comicNum) {
                await PersistenceProvider.default.storeComicMetadata(comicMetadata: fetchedMetadata)
            }
        }
    }
}
