//
//  ComicImage.swift
//  XKCDZ
//
//  Created by Adin on 5/25/22.
//

import Foundation

enum ComicImageSize: String {
    case Default = "Default"
    case Large = "Large"
}

enum ComicImageFileFormat: String {
    case JPEG = ".jpg"
    case PNG = ".png"
    case GIF = ".gif"
    case Unknown
    
    static func fromFilePath(_ addr: String) -> ComicImageFileFormat{
        guard let lastCharacter = addr.last,
              lastCharacter != "/",
              let lastPeriodIndex = addr.lastIndex(of: ".")
        else {
            return .Unknown
        }
        
        let fileExt = addr[lastPeriodIndex...addr.indices.last!]
        
        switch(fileExt) {
            case JPEG.rawValue:
                return .JPEG
                
            case PNG.rawValue:
                return .PNG
                
            case GIF.rawValue:
                return .GIF
                
            default:
                return .Unknown
        }
    }
}
