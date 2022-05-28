//
//  ComicFetcher.swift
//  XKCDZ
//
//  Created by Adin on 5/25/22.
//

import Foundation

actor ComicFetcher {
    static let shared: ComicFetcher = ComicFetcher()
    static let xkcdBaseUrl: URL = URL(string: "https://xkcd.com")!
    
    private var urlSession: URLSession = {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }()
    private var runningMetadataFetchTasks: [Int:Task<ComicMetadata?,Never>] = [:]
    private var runningComicImageFetchTasks: [ComicImageFetchSpec:Task<Data?,Never>] = [:]
    
    private init() {}
    
    func fetchComicMetadata(for comicNum: Int = 0) async -> ComicMetadata? {
        // NOTE(Adin): A comicNum of 0 fetches the latest metadata
        let fetchedMetadata: ComicMetadata?
        
        if let cachedTask = runningMetadataFetchTasks[comicNum] {
            fetchedMetadata = await cachedTask.value
        }
        else {
            let newTask = Task { () -> ComicMetadata? in
                defer {
                    runningMetadataFetchTasks[comicNum] = nil
                }
                
                let comicNumStr = comicNum == 0 ? "" : comicNum.description
                guard let metadtaUrl = URL(string: "\(comicNumStr)/info.0.json", relativeTo: ComicFetcher.xkcdBaseUrl)
                else {
                    return nil
                }
                
                guard let (responseData, _) = try? await performHttpRequest(from: metadtaUrl),
                      !Task.isCancelled
                else {
                    return nil
                }
                
                return try? JSONDecoder().decode(ComicMetadata.self, from: responseData)
            }
            
            runningMetadataFetchTasks[comicNum] = newTask
            fetchedMetadata = await newTask.value
        }
        
        return fetchedMetadata
    }
    
    func fetchComicImageData(for comicMetadata: ComicMetadata, ofSize imgSize: ComicImageSize = .Default) async -> Data? {
        let fetchedImageData: Data?
        
        guard comicMetadata.imgFileType != .Unknown
        else {
            return nil
        }
        
        let fetchSpec = ComicImageFetchSpec(comicMetadata: comicMetadata, imgSize: imgSize)
        
        if let cachedTask = runningComicImageFetchTasks[fetchSpec] {
            fetchedImageData = await cachedTask.value
        }
        else {
            let newTask = Task { () -> Data? in
                defer {
                    runningComicImageFetchTasks[fetchSpec] = nil
                }
                
                let fetchAddr: String
                
                if fetchSpec.imgSize == .Large {
                    guard let lastPeriodIndex = comicMetadata.imgLink.lastIndex(of: ".")
                    else {
                        return nil
                    }
                    
                    fetchAddr = comicMetadata.imgLink[comicMetadata.imgLink.indices.first!..<lastPeriodIndex] + "_2x" +
                                    comicMetadata.imgLink[lastPeriodIndex...comicMetadata.imgLink.indices.last!]
                }
                else {
                    fetchAddr = comicMetadata.imgLink
                }
                
                guard let imgUrl = URL(string: fetchAddr)
                else {
                    return nil
                }
                
                guard let (responseData, _) = try? await performHttpRequest(from: imgUrl)
                else {
                    return nil
                }
                
                return responseData
            }
            
            runningComicImageFetchTasks[fetchSpec] = newTask
            fetchedImageData = await newTask.value
        }
        
        return fetchedImageData
    }
    
    private func performHttpRequest(from url: URL) async throws -> (Data, HTTPURLResponse)? {
        let (data, urlResponse) = try await urlSession.data(from: url)
        
        guard let httpUrlResponse = urlResponse as? HTTPURLResponse
        else {
            return nil
        }
        
        switch(httpUrlResponse.statusCode) {
            case 100...199:
                throw HTTPError.ServerReturnedInformation(httpUrlResponse.statusCode)
            
            case 300...399:
                throw HTTPError.ServerReturnedRedirection(httpUrlResponse.statusCode)
            
            case 400...499:
                throw HTTPError.ServerReturnedClientError(httpUrlResponse.statusCode)
            
            case 500...599:
                throw HTTPError.ServerReturnedServerError(httpUrlResponse.statusCode)
            
            default:
                // Any other status code is a success
                break
        }
        
        return (data, httpUrlResponse)
    }
}

enum HTTPError: Error {
    case ServerReturnedInformation(Int)
    case ServerReturnedRedirection(Int)
    case ServerReturnedClientError(Int)
    case ServerReturnedServerError(Int)
}

private struct ComicImageFetchSpec: Hashable {
    let comicMetadata: ComicMetadata
    let imgSize: ComicImageSize
}
