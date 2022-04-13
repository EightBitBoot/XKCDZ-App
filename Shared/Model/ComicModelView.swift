//
//  ComicLoader2.swift
//  XKCDZ
//
//  Created by Adin on 4/13/22.
//

import Foundation
import SwiftUI


class ComicModelView: ObservableObject {
    @Published public private(set) var image: Image? = nil
    @Published public private(set) var errorLoading: Bool = false
    
    @MainActor
    func load(_ comicNum: Int) async {
        // TODO(Adin): Clean up error handling
        // TODO(Adin): Check comic cache first
        
        let comicMetadata: ComicMetadata
        do {
            comicMetadata = try await ComicLoader.getComicMetadata(comicNum: comicNum)
        }
        catch ComicLoaderError.InvalidUrl(let address) {
            print("MetadataFetch: Invalid url: \(address)!")
            errorLoading = true
            return
        }
        catch ComicLoaderError.NotAHttpResponse {
            print("MetadataFetch: URLSession.shared.data(from: url) didn't return a HTTPURLResponse!")
            errorLoading = true
            return
        }
        catch ComicLoaderError.ServerErrorCode(let httpResponseCode) {
            print("MetadataFetch: The server responsed with error code \(httpResponseCode)!")
            errorLoading = true
            return
        }
        catch {
            print("MetadataFetch: Unknown Error:\n\(error)")
            errorLoading = true
            return
        }
        
        let imageData: Data
        do {
            imageData = try await ComicLoader.getComicImage(comicMetadata: comicMetadata)
        }
        catch ComicLoaderError.InvalidUrl(let address) {
            print("ImageFetch: Invalid url: \(address)!")
            errorLoading = true
            return
        }
        catch ComicLoaderError.NotAHttpResponse {
            print("ImageFetch: URLSession.shared.data(from: url) didn't return a HTTPURLResponse!")
            errorLoading = true
            return
        }
        catch ComicLoaderError.ServerErrorCode(let httpResponseCode) {
            print("ImageFetch: The server responsed with error code \(httpResponseCode)!")
            errorLoading = true
            return
        }
        catch {
            print("ImageFetch: Unknown Error:\n\(error)")
            errorLoading = true
            return
        }
        
        guard let uiImage: UIImage = UIImage(data: imageData)
        else {
            print("Error loading image data into UIImage")
            errorLoading = true
            return
        }
        
        self.image = Image(uiImage: uiImage)
    }
    
}
