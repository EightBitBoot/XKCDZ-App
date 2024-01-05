//
//  ComicShop.swift
//  xkcdz
//
//  Created by Adin W-T on 12/29/23.
//

import Foundation
import RealmSwift

class ComicShop {
    func getMeta(for comicNum: Int? = nil) async throws -> ComicMeta {
        return try await downloadMeta(for: comicNum)
    }
}

//MARK: - Downloads

private extension ComicShop {
    static let XKCD_META_FILENAME: String = "info.0.json"
    static let XKCD_BASE_URL: URL = URL(string: "https://xkcd.com/")!
    static let XKCD_LATEST_META_URL: URL = XKCD_BASE_URL.appending(component: XKCD_META_FILENAME)
    
    enum ComicShopDownloadError: Error {
        case InvalidResponseTypeError
        case HTTPResponseCodeError(Int)
        case InvalidComicNum(Int)
    }
    
    func downloadData(from url: URL) async throws -> Data {
        let (data, response): (Data, URLResponse) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse
        else {
            throw ComicShopDownloadError.InvalidResponseTypeError
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            // Success
            break
            
        default:
            throw ComicShopDownloadError.HTTPResponseCodeError(httpResponse.statusCode)
        }
        
        return data
    }
    
    func downloadMeta(for comicNum: Int? = nil) async throws -> ComicMeta {
        // By default, download the latest meta if no comic num is provided
        var metaUrl: URL = ComicShop.XKCD_LATEST_META_URL
        if let comicNum = comicNum {
            if comicNum < 1 {
                throw ComicShopDownloadError.InvalidComicNum(comicNum)
            }
            
            metaUrl = ComicShop.XKCD_BASE_URL.appendingPathComponent(String(comicNum)).appendingPathComponent(ComicShop.XKCD_META_FILENAME)
        }
        
        let data = try await downloadData(from: metaUrl)
        return try JSONDecoder().decode(ComicMeta.self, from: data)
    }
    
    // TODO(Adin): Download Images
}
