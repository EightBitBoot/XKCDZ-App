//
//  ComicListModelView.swift
//  XKCDZ
//
//  Created by Adin on 4/13/22.
//

import Foundation

class ComicListModelView: ObservableObject {
    @Published var latestComicNum: Int? = nil
    @Published var errorLoading: Bool = false
    
    @MainActor
    func loadLatestComicNum() async {
        let comicMetadata: ComicMetadata
        do {
            comicMetadata = try await ComicLoader.getComicMetadata()
        }
        catch ComicLoaderError.InvalidUrl(let address) {
            print("LatestNumFetch: Invalid url: \(address)!")
            errorLoading = true
            return
        }
        catch ComicLoaderError.NotAHttpResponse {
            print("LatestNumFetch: URLSession.shared.data(from: url) didn't return a HTTPURLResponse!")
            errorLoading = true
            return
        }
        catch ComicLoaderError.ServerErrorCode(let httpResponseCode) {
            print("LatestNumFetch: The server responsed with error code \(httpResponseCode)!")
            errorLoading = true
            return
        }
        catch {
            print("LatestNumFetch: Unknown Error:\n\(error)")
            errorLoading = true
            return
        }
        
        latestComicNum = comicMetadata.num
    }
}
