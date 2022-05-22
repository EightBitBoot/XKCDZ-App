//
//  Comic.swift
//  XKCDZ
//
//  Created by Adin on 4/12/22.
//

import Foundation

let XKCD_BASE_URL = "https://xkcd.com/"

protocol ToSafeType {
    associatedtype SafeType
    func toSafeType() throws -> SafeType
}

enum SafeMapError: Error {
    case InvalidMapping
}

struct ComicMetadata {
    let num: Int
    let img: String
    let safe_title: String
    let alt: String
    let date: Date
    let title: String
    let transcript: String
    let link: String
    let news: String
    
    fileprivate init(num: Int,
                     img: String,
                     safe_title: String,
                     alt: String,
                     date: Date,
                     title: String,
                     transcript: String,
                     link: String,
                     news: String)
    {
        self.num = num
        self.img = img
        self.safe_title = safe_title
        self.alt = alt
        self.date = date
        self.title = title
        self.transcript = transcript
        self.link = link
        self.news = news
    }
}

extension ComicMetadata: Decodable {
    private enum DecodingKeys: String, CodingKey {
        case num = "num"
        case img = "img"
        case safe_title = "safe_title"
        case alt = "alt"
        case year = "year"
        case month = "month"
        case day = "day"
        case title = "title"
        case transcript = "transcript"
        case link = "link"
        case news = "news"
        case extra_parts = "extra_parts"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        
        let num: Int = try container.decode(Int.self, forKey: .num)
        let img: String = try container.decode(String.self, forKey: .img)
        let safe_title: String = try container.decode(String.self, forKey: .safe_title)
        let alt: String = try container.decode(String.self, forKey: .alt)
        
        let year: String = try container.decode(String.self, forKey: .year)
        let month: String = try container.decode(String.self, forKey: .month)
        let day: String = try container.decode(String.self, forKey: .day)
        
        let date: Date
        if let year: Int = Int(year),
           let month: Int = Int(month),
           let day: Int = Int(day),
           let decodedDate: Date = DateComponents(calendar: Calendar(identifier: Calendar.Identifier.iso8601), timeZone: TimeZone(abbreviation: "EST"), year: year, month: month, day: day).date
        {
           date = decodedDate
        }
        else {
            date = Date(timeIntervalSince1970: TimeInterval())
        }
        
        let title: String = try container.decode(String.self, forKey: .title)
        let transcript: String = try container.decode(String.self, forKey: .transcript)
        let link: String = try container.decode(String.self, forKey: .link)
        let news: String = try container.decode(String.self, forKey: .news)
        
        self.init(num: num,
                  img: img,
                  safe_title: safe_title,
                  alt: alt,
                  date: date,
                  title: title,
                  transcript: transcript,
                  link: link,
                  news: news)
    }
}

extension StoredComicMetadata: ToSafeType {
    func toSafeType() throws -> ComicMetadata {
        // num isn't optional so it's not in the guard statement
        guard let img = self.img,
              let safe_title = self.safe_title,
              let alt = self.alt,
              let date = self.date,
              let title = self.title,
              let transcript = self.transcript,
              let link = self.link,
              let news = self.news
        else {
            throw SafeMapError.InvalidMapping
        }
        
        return ComicMetadata(num: Int(num),
                             img: img,
                             safe_title: safe_title,
                             alt: alt,
                             date: date,
                             title: title,
                             transcript: transcript,
                             link: link,
                             news: news)
    }
}

struct ComicImage {
    let num: Int
    let data: Data
    let ratio: Float
}

extension StoredComicImage: ToSafeType {
    func toSafeType() throws -> ComicImage {
        // num and ratio aren't optional so they're not in the guard statement
        guard let data = self.data
        else {
            throw SafeMapError.InvalidMapping
        }
        
        return ComicImage(num: Int(num), data: data, ratio: self.ratio)
    }
}
