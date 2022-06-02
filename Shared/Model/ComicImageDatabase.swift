//
//  ComicImageDatabase.swift
//  XKCDZ
//
//  Created by Adin on 5/25/22.
//

import Foundation

// Needss to be at a file level for both ComicImageDatabase and ComicImageRequest+Url
    
actor ComicImageDatabase {
    static let shared: ComicImageDatabase = ComicImageDatabase()
    
    let imgCacheUrl: URL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent("ComicImages", isDirectory: true)
    
    private var runningStoreTasks: [ComicImageRequest:Task<(),Error>] = [:]
    private var runningGetTasks: [ComicImageRequest:Task<Data,Error>] = [:]
    
    private init() {}
    
    func hasComicImage(of imgRequest: ComicImageRequest) async -> Bool {
        if let runningTask = runningStoreTasks[imgRequest] {
            do {
                try await runningTask.value
            }
            catch {
                // The running save task failed
                return false
            }
            
            // The running save task suceeded
            return true
        }
        
        // There isn't a running save task for the file
        let fileUrl = imgRequest.fileUrl
        return FileManager.default.fileExists(atPath: fileUrl.path)
    }
    
    func storeComicImage(of imgRequest: ComicImageRequest, withContents imgData: Data) async throws {
        if await hasComicImage(of: imgRequest) {
            // hasComicImage(of:) already awaits any running store
            // tasks for the current imgRequest so no additional
            // waiting is required
            
            // Avoid duplicates
            throw ComicImageDatabaseError.ImageAlreadyStored
        }
        
        let newTask = Task {
            defer {
                runningStoreTasks[imgRequest] = nil
            }
            
            if !FileManager.default.fileExists(atPath: imgRequest.dirUrl.path) {
                try FileManager.default.createDirectory(at: imgRequest.dirUrl, withIntermediateDirectories: true)
            }
            
            try imgData.write(to: imgRequest.fileUrl, options: .atomic)
        }
        
        runningStoreTasks[imgRequest] = newTask
        try await newTask.value
    }
    
    func getComicImage(of imgRequest: ComicImageRequest) async throws -> Data {
        if let runningTask = runningGetTasks[imgRequest] {
            return try await runningTask.value
        }
        
        let newTask = Task { () -> Data in
            defer {
                runningGetTasks[imgRequest] = nil
            }
            
            return try Data(contentsOf: imgRequest.fileUrl)
        }
        
        runningGetTasks[imgRequest] = newTask
        return try await newTask.value
    }
}

enum ComicImageDatabaseError: Error {
    case ImageAlreadyStored
}

extension ComicImageRequest {
    var dirUrl: URL {
        return ComicImageDatabase.shared.imgCacheUrl.appendingPathComponent(comicMetadata.comicNum.description, isDirectory: true)
    }
    
    var fileUrl: URL {
        return dirUrl.appendingPathComponent("\(imgSize.rawValue)\(comicMetadata.imgFileType.rawValue)", isDirectory: false)
    }
}
