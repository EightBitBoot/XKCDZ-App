//
//  ComicStore.swift
//  XKCDZ
//
//  Created by Adin on 4/13/22.
//

import Foundation

enum FileFormat: String {
    case JPEG = ".jpg"
    case PNG = ".png"
}

class ComicStore {
    static func getMetadata(_ comicNum: Int) async -> ComicMetadata? {
        if let storedMetadata = PersistenceProvider.default.getComicMetadata(comicNum) {
            return storedMetadata
        }
        
        // TODO(Adin): Error printing?
        guard let jsonMetadata = try? await ComicLoader.getComicMetadata(comicNum: comicNum)
        else {
            // Error fetching comic metadata
            return nil
        }
        
        return PersistenceProvider.default.createComicMetadata(jsonComicMetadata: jsonMetadata)
    }
    
    static func getLatestStoredMetadata() -> ComicMetadata? {
        return PersistenceProvider.default.getLatestStoredMetadata()
    }
    
    static func getImage(_ comicNum: Int) async -> ComicImage? {
        guard let comicMetadata = await getMetadata(comicNum)
        else {
            // Stored metadata doesn't exist and there was an error fetching it from the server
            return nil
        }
        
        if comicMetadata.comicImage != nil {
            return comicMetadata.comicImage!
        }
        
        // WHY IS comicMetadata.img AN OPTIONAL????
        guard let fetchedImage = try? await ComicLoader.getComicImageData(imgAddress: comicMetadata.img!)
        else {
            // Error fetching comic image data
            return nil
        }
        
        return PersistenceProvider.default.createComicImage(comicMetadata: comicMetadata, data: fetchedImage)
    }
    
    static func refreshComicStore() async {
        guard let latestMetadata = try? await ComicLoader.getComicMetadata()
        else {
            // TODO(Adin): This doesn't need to be fatal
            fatalError("Error refreshing comic store from server")
        }
        
        let baseComicNum: Int
        if let latestStoredMetadata = PersistenceProvider.default.getLatestStoredMetadata() {
            baseComicNum = Int(latestStoredMetadata.num)
        }
        else {
            // Loading 100 comics is arbitrary and can be changed later if needed
            baseComicNum = latestMetadata.num - 100 >= 1 ? Int(latestMetadata.num) - 100 : 1
        }
        
        // .reversed() to load the comics newest -> oldest
        for comicNum in (baseComicNum...Int(latestMetadata.num)).reversed() {
            if let jsonMetadata = try? await ComicLoader.getComicMetadata(comicNum: comicNum) {
                PersistenceProvider.default.createComicMetadata(jsonComicMetadata: jsonMetadata)
            }
        }
    }
}
