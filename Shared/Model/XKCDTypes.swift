//
//  Comic.swift
//  XKCDZ
//
//  Created by Adin on 4/12/22.
//

import Foundation
import SwiftUI

let XKCD_BASE_URL = "https://xkcd.com/"

// TODO(Adin): Collapse JsonComicMetadata and SafeComicMetadata into one
//             struct

// TODO(Adin): Decode day, month & year as Ints
struct JsonComicMetadata: Codable {
    let num: Int
    let img: String
    let safe_title: String
    let alt: String
    let day: String
    let month: String
    let year: String
    let title: String
    let transcript: String
    let link: String
    let news: String
    let extra_parts: [String:String]?
}

struct SafeComicMetadata {
    let num: Int
    let img: String
    let safe_title: String
    let alt: String
    let day: String
    let month: String
    let year: String
    let title: String
    let transcript: String
    let link: String
    let news: String
}

extension ComicMetadata: ToSafeType {
    func toSafeType() throws -> SafeComicMetadata {
        // For whatever reason num isn't optional so it isn't required
        // in the guard statement
        guard let img = self.img,
              let safe_title = self.safe_title,
              let alt = self.alt,
              let day = self.day,
              let month = self.month,
              let year = self.year,
              let title = self.title,
              let transcript = self.transcript,
              let link = self.link,
              let news = self.news
        else {
            throw SafeMapError.InvalidMapping
        }
        
        return SafeComicMetadata(num: Int(num),
                                 img: img,
                                 safe_title: safe_title,
                                 alt: alt,
                                 day: day,
                                 month: month,
                                 year: year,
                                 title: title,
                                 transcript: transcript,
                                 link: link,
                                 news: news)
    }
}
