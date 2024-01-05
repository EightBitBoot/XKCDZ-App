//
//  ComicInfo.swift
//  xkcdz
//
//  Created by Adin W-T on 6/28/23.
//

import Foundation
import RealmSwift

class ComicMeta: Object, Identifiable, Decodable {
    private static var initializerUsed = false
    
    @Persisted(primaryKey: true) private(set) var id: Int // "num" in Json
    
    @Persisted private(set) var title: String
    @Persisted private(set) var safeTitle: String
    @Persisted private(set) var alt: String
    
    @Persisted private(set) var date: Date
    
    @Persisted private(set) var img: String
    @Persisted private(set) var transcript: String
    @Persisted private(set) var link: String
    
    @Persisted private(set) var extraParts: ExtraParts?
    
    enum CodingKeys: String, CodingKey {
        case id = "num"
        
        case title
        case safeTitle = "safe_title"
        case alt
        
        case year
        case month
        case day
        
        case img
        case transcript
        case link
        
        case extraParts = "extra_parts"
    }
    
    // {'month', 'extra_parts', 'day', 'transcript', 'safe_title', 'year', 'img', 'title', 'alt', 'num', 'news', 'link'}
    
    override init() {
        if ComicMeta.initializerUsed {
            fatalError("This initializer must only be called once by realm")
        }
        else {
            ComicMeta.initializerUsed = true
        }
        
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        
        title = try values.decode(String.self, forKey: .title)
        safeTitle = try values.decode(String.self, forKey: .safeTitle)
        alt = try values.decode(String.self, forKey: .alt)
        
        var dateComponents = DateComponents()
        dateComponents.year = try Int(values.decode(String.self, forKey: .year)) ?? 1970
        dateComponents.month = try Int(values.decode(String.self, forKey: .month)) ?? 1
        dateComponents.day = try Int(values.decode(String.self, forKey: .day)) ?? 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.timeZone = TimeZone.current
        date = Calendar(identifier: .gregorian).date(from: dateComponents) ?? Date(timeIntervalSince1970: .zero)
        
        img = try values.decode(String.self, forKey: .img)
        transcript = try values.decode(String.self, forKey: .link)
        link = try values.decode(String.self, forKey: .link)
        
        extraParts = try values.decodeIfPresent(ExtraParts.self, forKey: .extraParts)
    }
}

#if DEBUG
extension ComicMeta {
    func dump() {
        print("ComicMeta:")
        print("     id: \(id)")
        print("     title: \(title)")
        print("     safeTitle: \(safeTitle)")
        print("     alt: \(alt)")
        print("     date: \(date)")
        print("     img: \(img)")
        print("     transcript: \(transcript)")
        print("     link: \(link)")
        print("     extraParts:")
        extraParts?.dump()
    }
}
#endif

// MARK: - Extra Parts

extension ComicMeta {
    @objc(ExtraParts) // Required by realm because this isn't a public, top-level class
    class ExtraParts: EmbeddedObject, Decodable {
        static var initializerUsed = false
        
        @Persisted var headerExtra: String?
        @Persisted var imgAttr: String?
        @Persisted var inset: String?
        @Persisted var links: String?
        @Persisted var pre: String?
        @Persisted var post: String?

        enum CodingKeys: String, CodingKey {
            case headerExtra = "headerextra"
            case imgAttr
            case inset
            case links
            case pre
            case post
        }
        
        override init() {
            if ExtraParts.initializerUsed {
                fatalError("This initializer is only to be called once by realm")
            }
            else {
                ExtraParts.initializerUsed = true
            }
            
            super.init()
            
        }

        required init(from decoder: Decoder) throws {
            super.init()
            
            let values = try decoder.container(keyedBy: CodingKeys.self)

            headerExtra = try values.decodeIfPresent(String.self, forKey: .headerExtra)
            imgAttr = try values.decodeIfPresent(String.self, forKey: .imgAttr)
            inset = try values.decodeIfPresent(String.self, forKey: .inset)
            links = try values.decodeIfPresent(String.self, forKey: .links)
            pre = try values.decodeIfPresent(String.self, forKey: .pre)
            post = try values.decodeIfPresent(String.self, forKey: .post)
        }
    }
}

#if DEBUG
extension ComicMeta.ExtraParts {
    func dump() {
        print("        headerExtra: \(headerExtra ?? "")")
        print("        imgAttr: \(imgAttr ?? "")")
        print("        inset: \(inset ?? "")")
        print("        links: \(links ?? "")")
        print("        pre: \(pre ?? "")")
        print("        post: \(post ?? "")")
    }
}
#endif

// MARK: - Testing Data

#if DEBUG
extension ComicMeta {
    static let extraPartsComicData: [String] = [
    ]
}
#endif
