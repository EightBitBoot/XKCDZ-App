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
    
    func load(_ comicNum: Int, size: ComicImageSize = .Default) async {
        if let loadedImage = await ComicStore.shared.getComicImage(for: comicNum, ofSize: size) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self
                else {
                    return
                }
                
                self.image = Image(uiImage: loadedImage)
            }
        }
        else {
            errorLoading = true
        }
    }
}
