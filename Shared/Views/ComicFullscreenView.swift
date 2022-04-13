//
//  ComicFullscreenView.swift
//  XKCDZ
//
//  Created by Adin on 4/13/22.
//

import SwiftUI

struct ComicFullscreenView: View {
    var comicNum: Int
    
    var body: some View {
        ComicImageView(comicNum: comicNum)
            .navigationTitle(comicNum.description)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct ComicFullscreenView_Previews: PreviewProvider {
    static var previews: some View {
        ComicFullscreenView(comicNum: 110)
    }
}
