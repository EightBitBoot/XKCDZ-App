//
//  ComicFullscreenModelView.swift
//  XKCDZ
//
//  Created by Adin on 4/15/22.
//

import Foundation

class ComicMetadataModelView: ObservableObject {
    @Published var comicMetadata: ComicMetadata? = nil
    
    @MainActor
    func load(_ comicNum: Int) async {
        if let comicMetadata = await ComicStore.shared.getComicMetadata(for: comicNum) {
            self.comicMetadata = comicMetadata
        }
    }
}
