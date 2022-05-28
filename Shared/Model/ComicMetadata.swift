//
//  StoredComicMetadata.swift
//  XKCDZ
//
//  Created by Adin on 5/25/22.
//

import Foundation
import CoreData

struct ComicMetadata: Decodable, Hashable {
    let comicNum: Int
    let safeTitle: String
    let imgLink: String
    let altText: String
    let datePublished: Date
    let externalLink: String
    let news: String
    let title: String
    let transcript: String
    let extraParts: [String:String]
    let imgRatio: Float?
    
    let imgFileType: ComicImageFileFormat
    
    static let calendar: Calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    static let timeZone: TimeZone = TimeZone(secondsFromGMT: -18000)! // EST; Arbitrary choice: comic dates don't have a time
    
    private static let decodeTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = ComicMetadata.calendar
        formatter.timeZone = ComicMetadata.timeZone
        formatter.dateFormat = "yyyy.M.d"
        return formatter
    }()
    
    var isSpecial: Bool {
        return !extraParts.isEmpty
    }
    
    private enum JsonCodingKeys: String, CodingKey {
        case num = "num"
        case safe_title = "safe_title"
        case img = "img"
        case alt = "alt"
        case year = "year"
        case month = "month"
        case day = "day"
        case link = "link"
        case news = "news"
        case title = "title"
        case transcript = "transcript"
        case extra_parts = "extra_parts"
    }
    
    init(from decoder: Decoder) throws {
        let topContainer = try decoder.container(keyedBy: JsonCodingKeys.self)
        
        comicNum = try topContainer.decode(Int.self, forKey: .num)
        safeTitle = try topContainer.decode(String.self, forKey: .safe_title)
        imgLink = try topContainer.decode(String.self, forKey: .img)
        altText = try topContainer.decode(String.self, forKey: .alt)
        
        let year: String = (try? topContainer.decode(String.self, forKey: .year)) ?? ""
        let month: String = (try? topContainer.decode(String.self, forKey: .month)) ?? ""
        let day: String = (try? topContainer.decode(String.self, forKey: .day)) ?? ""
        datePublished = ComicMetadata.decodeTimeFormatter.date(from: "\(year).\(month).\(day)") ?? Date(timeIntervalSince1970: .zero)
        
        externalLink = try topContainer.decode(String.self, forKey: .link)
        news = try topContainer.decode(String.self, forKey: .news)
        title = try topContainer.decode(String.self, forKey: .title)
        transcript = try topContainer.decode(String.self, forKey: .transcript)
        extraParts = try topContainer.decodeIfPresent([String:String].self, forKey: .extra_parts) ?? [:]
        
        imgRatio = nil
        
        imgFileType = ComicImageFileFormat.fromFilePath(imgLink)
    }
}

