//
//  ComicLoader.swift
//  XKCDZ
//
//  Created by Adin on 4/13/22.
//

import Foundation

enum ComicLoaderError: Error {
    case InvalidUrl(String)
    case NotAHttpResponse
    case ServerErrorCode(Int)
    case None
}

struct ComicLoader {
    // This is an organizational struct with static functions
    // so prevent instantiation
    private init() {}
    
    private static func httpGetRequest(_ address: String) async throws -> (Data, HTTPURLResponse) {
        guard let url: URL = URL(string: address)
        else {
            throw ComicLoaderError.InvalidUrl(address)
        }
                
        let dataResult: (Data, URLResponse) = try await URLSession.shared.data(from: url)
        
        guard let htmlResponse = dataResult.1 as? HTTPURLResponse
        else {
            throw ComicLoaderError.NotAHttpResponse
        }
        
        if !(200...299).contains(htmlResponse.statusCode) {
            throw ComicLoaderError.ServerErrorCode(htmlResponse.statusCode)
        }
        
        return (dataResult.0, htmlResponse)
    }
    
    static func getComicMetadata(comicNum: Int? = nil) async throws -> JsonComicMetadata {
        let address: String = (comicNum == nil ? XKCD_BASE_URL + "info.0.json" : XKCD_BASE_URL + "\(comicNum!)/info.0.json")
        let getResult: (Data, HTTPURLResponse) = try await httpGetRequest(address)
        return try JSONDecoder().decode(JsonComicMetadata.self, from: getResult.0)
    }
    
    static func getComicImageData(imgAddress: String) async throws -> Data {
        if let fileExtensionPeriodLocation = imgAddress.lastIndex(of: ".") {
            // There is at least one period in imgAddress
            let fullResAddress = imgAddress[imgAddress.startIndex..<fileExtensionPeriodLocation] + "_2x" + imgAddress[fileExtensionPeriodLocation..<imgAddress.endIndex]
            if let fullResGetResult: (Data, HTTPURLResponse) = try? await httpGetRequest(String(fullResAddress)) {
                // The get request to the 2x url suceeded, return the 2x image data
                return fullResGetResult.0
            }
        }
        
        // Fallback to the 1x image url and response
        let getResult: (Data, HTTPURLResponse) = try await httpGetRequest(imgAddress)
        return getResult.0
    }
}
