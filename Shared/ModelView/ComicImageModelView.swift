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
        // TODO(Adin): Clean up error handling
        // TODO(Adin): Check comic cache first
        
        if let loadedImageData = await ComicStore.getImage(comicNum), let uiImage = UIImage(data: loadedImageData.data!) {
            image = Image(uiImage: uiImage)
        }
        else {
            errorLoading = true
        }
    }
}
