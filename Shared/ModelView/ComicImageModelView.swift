//
//  ComicLoader2.swift
//  XKCDZ
//
//  Created by Adin on 4/13/22.
//

import Foundation
import SwiftUI


class ComicImageModelView: ObservableObject {
    @Published public private(set) var image: Image? = nil
    @Published public private(set) var errorLoading: Bool = false
    
    @MainActor
    func load(_ comicNum: Int) async {
        if let loadedImage = await ComicStore.getComicImage(comicNum) {
            image = loadedImage
        }
        else {
            errorLoading = true
        }
    }
}
