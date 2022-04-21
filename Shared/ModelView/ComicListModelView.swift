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
        if let latestComicMetadata = await ComicStore.getLatestStoredMetadata() {
            latestComicNum = Int(latestComicMetadata.num)
        }
        else {
            // No comics stored in store
            
            await ComicStore.refreshComicStore()
            // TODO(Adin): This nested if is ugly: fix it
            if let newLatestComicMetadata = await ComicStore.getLatestStoredMetadata() {
                latestComicNum = Int(newLatestComicMetadata.num)
            }
            else {
                // TODO(Adin): This doesn't need to be a fatal error
                fatalError("Error loading comics into empty store")
            }
        }
    }
    
    func refresh() async {
        await ComicStore.refreshComicStore()
        await loadLatestComicNum()
    }
}
