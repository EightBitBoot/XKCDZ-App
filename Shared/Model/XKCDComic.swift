//
//  Comic.swift
//  XKCDZ
//
//  Created by Adin on 4/12/22.
//

import Foundation
import SwiftUI

let XKCD_BASE_URL = "https://xkcd.com/"

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
