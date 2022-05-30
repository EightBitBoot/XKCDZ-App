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
        if let latestComicMetadata = await ComicStore.shared.getComicMetadata() {
            latestComicNum = latestComicMetadata.comicNum
        }
        else {
            // No comics stored in store
            
            await ComicStore.shared.refreshComicStore()
            // TODO(Adin): This nested if is ugly: fix it
            if let newLatestComicMetadata = await ComicStore.shared.getComicMetadata() {
                latestComicNum = newLatestComicMetadata.comicNum
            }
            else {
                // TODO(Adin): This doesn't need to be a fatal error
                fatalError("Error loading comics into empty store")
            }
        }
    }
    
    func refresh() async {
        await ComicStore.shared.refreshComicStore()
        await loadLatestComicNum()
    }
}
