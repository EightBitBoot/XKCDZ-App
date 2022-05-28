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
    private var runningMetadataFetchTasks: [Int:Task<ComicMetadata,Error>] = [:]
    private var runningComicImageFetchTasks: [ComicImageRequest:Task<Data,Error>] = [:]
    
    private init() {}
    
    func fetchComicMetadata(for comicNum: Int = 0) async throws -> ComicMetadata {
        // NOTE(Adin): A comicNum of 0 fetches the latest metadata
        let fetchedMetadata: ComicMetadata
        
        if let cachedTask = runningMetadataFetchTasks[comicNum] {
            fetchedMetadata = try await cachedTask.value
        }
        else {
            let newTask = Task { () -> ComicMetadata in
                defer {
                    runningMetadataFetchTasks[comicNum] = nil
                }
                
                let comicNumStr = comicNum == 0 ? "" : comicNum.description
                guard let metadtaUrl = URL(string: "\(comicNumStr)/info.0.json", relativeTo: ComicFetcher.xkcdBaseUrl)
                else {
                    throw FetchError.InvalidUrlConstruction
                }
                
                let (responseData, _) = try await performHttpRequest(from: metadtaUrl)
                try Task.checkCancellation()
                
                return try JSONDecoder().decode(ComicMetadata.self, from: responseData)
            }
            
            runningMetadataFetchTasks[comicNum] = newTask
            fetchedMetadata = try await newTask.value
        }
        
        return fetchedMetadata
    }
    
    func fetchComicImageData(for imgRequest: ComicImageRequest) async throws -> Data {
        let fetchedImageData: Data
        
        guard imgRequest.comicMetadata.imgFileType != .Unknown
        else {
            throw FetchError.InvalidComicImageFileType
        }
        
        if let cachedTask = runningComicImageFetchTasks[imgRequest] {
            fetchedImageData = try await cachedTask.value
        }
        else {
            let newTask = Task { () -> Data in
                defer {
                    runningComicImageFetchTasks[imgRequest] = nil
                }
                
                let fetchAddr: String
                
                if imgRequest.imgSize == .Large {
                    guard let lastPeriodIndex = imgRequest.comicMetadata.imgLink.lastIndex(of: ".")
                    else {
                        throw FetchError.InvalidComicImageLink
                    }
                    
                    fetchAddr = imgRequest.comicMetadata.imgLink[imgRequest.comicMetadata.imgLink.indices.first!..<lastPeriodIndex] + "_2x" +
                                imgRequest.comicMetadata.imgLink[lastPeriodIndex...imgRequest.comicMetadata.imgLink.indices.last!]
                }
                else {
                    fetchAddr = imgRequest.comicMetadata.imgLink
                }
                
                guard let imgUrl = URL(string: fetchAddr)
                else {
                    throw FetchError.InvalidUrlConstruction
                }
                
                let (responseData, _) = try await performHttpRequest(from: imgUrl)
                
                return responseData
            }
            
            runningComicImageFetchTasks[imgRequest] = newTask
            fetchedImageData = try await newTask.value
        }
        
        return fetchedImageData
    }
    
    private func performHttpRequest(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let (data, urlResponse) = try await urlSession.data(from: url)
        
        guard let httpUrlResponse = urlResponse as? HTTPURLResponse
        else {
            throw FetchError.NotAHttpResponse
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

enum FetchError: Error {
    case InvalidUrlConstruction
    case InvalidComicImageLink
    case InvalidComicImageFileType
    case NotAHttpResponse
}

enum HTTPError: Error {
    case ServerReturnedInformation(Int)
    case ServerReturnedRedirection(Int)
    case ServerReturnedClientError(Int)
    case ServerReturnedServerError(Int)
}

