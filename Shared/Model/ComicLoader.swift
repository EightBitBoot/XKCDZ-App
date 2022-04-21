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
        let getResult: (Data, HTTPURLResponse) = try await httpGetRequest(imgAddress)
        return getResult.0
    }
}
