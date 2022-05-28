//
//  StoredComicMetadata.swift
//  XKCDZ
//
//  Created by Adin on 5/25/22.
//

import Foundation
import CoreData

protocol SafeTypeConvertable {
    associatedtype SafeType
    
    func toSafeType() throws -> SafeType
    static func fromSafeType(context: NSManagedObjectContext, copyOf safeType: SafeType) -> Self
}

enum SafeTypeError: Error {
    case InvalidMappingError
}

@objc(StoredComicMetadata)
final class StoredComicMetadata: NSManagedObject {
}

extension StoredComicMetadata: SafeTypeConvertable {
    func toSafeType() throws -> ComicMetadata {
        // TODO(Adin): Finish this
        guard let safe_title = safe_title,
              let img_link = img_link,
              let alt_text = alt_text,
              let date_published = date_published,
              let external_link = external_link,
              let news = news,
              let title = title,
              let transcript = transcript
        else {
            throw SafeTypeError.InvalidMappingError
        }
        
        var extraParts: [String:String] = [:]
        if let extra_parts_headerextra = extra_parts_headerextra {
            extraParts["headerextra"] = extra_parts_headerextra
        }
        if let extra_parts_inset = extra_parts_inset {
            extraParts["inset"] = extra_parts_inset
        }
        
        return ComicMetadata(comicNum: Int(comic_num),
                             safeTitle: safe_title,
                             imgLink: img_link,
                             altText: alt_text,
                             datePublished: date_published,
                             externalLink: external_link,
                             news: news,
                             title: title,
                             transcript: transcript,
                             extraParts: extraParts,
                             imgRatio: img_ratio == 0.0 ? nil : img_ratio)
    }
    
    static func fromSafeType(context: NSManagedObjectContext, copyOf safeMetadata: ComicMetadata) -> StoredComicMetadata {
        let newMetadata = StoredComicMetadata(context: context)
        
        newMetadata.comic_num = Int32(safeMetadata.comicNum)
        newMetadata.safe_title = safeMetadata.safeTitle
        newMetadata.img_link = safeMetadata.imgLink
        newMetadata.alt_text = safeMetadata.altText
        newMetadata.date_published = safeMetadata.datePublished
        newMetadata.external_link = safeMetadata.externalLink
        newMetadata.news = safeMetadata.news
        newMetadata.title = safeMetadata.title
        newMetadata.transcript = safeMetadata.transcript
        newMetadata.extra_parts_headerextra = safeMetadata.extraParts["headerextra"]
        newMetadata.extra_parts_inset = safeMetadata.extraParts["inset"]
        newMetadata.img_ratio = safeMetadata.imgRatio ?? 0.0
        
        return newMetadata
    }
}

private extension ComicMetadata {
    init(comicNum: Int,
         safeTitle: String,
         imgLink: String,
         altText: String,
         datePublished: Date,
         externalLink: String,
         news: String,
         title: String,
         transcript: String,
         extraParts: [String:String],
         imgRatio: Float?)
    {
        self.comicNum = comicNum
        self.safeTitle = safeTitle
        self.imgLink = imgLink
        self.altText = altText
        self.datePublished = datePublished
        self.externalLink = externalLink
        self.news = news
        self.title = title
        self.transcript = transcript
        self.extraParts = extraParts
        self.imgRatio = imgRatio
    }
    
}
