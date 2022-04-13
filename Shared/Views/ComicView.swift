//
//  ComicView.swift
//  XKCDZ
//
//  Created by Adin on 4/12/22.
//

import SwiftUI

// TODO(Adin): ProgressView while loading

struct ComicView: View {
    var comicNum: Int
    @StateObject private var comicLoader: ComicLoader = ComicLoader()
    
    var body: some View {
        Group { // Wrapper group for .onAppear
            if comicLoader.image == nil {
                ProgressView()
                    .onAppear { comicLoader.load(comicNum) }
            }
            else {
                comicLoader.image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ComicView(comicNum: 1537)
        ComicView(comicNum: 1302)
    }
}
