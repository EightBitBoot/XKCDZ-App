//
//  ComicView.swift
//  XKCDZ
//
//  Created by Adin on 4/12/22.
//

import SwiftUI

// TODO(Adin): ProgressView while loading

struct ComicImageView: View {
    var comicNum: Int
    @StateObject private var comicModelView: ComicModelView = ComicModelView()
    
    var body: some View {
        Group {
            if comicModelView.errorLoading {
                // Error loading the comic
                
                // TODO(Adin): Make this bigger and more descriptive
                Label("Error loading comic image", systemImage: "xmark.octagon")
                    .labelStyle(.iconOnly)
            }
            else {
                // No error loading the comic or it hasn't loaded yet
                
                if comicModelView.image == nil {
                    // TODO(Adin): Maybe make this a bit bigger
                    ProgressView()
                        .task {
                            await comicModelView.load(comicNum)
                        }
                }
                else {
                    comicModelView.image?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
    }
}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ComicImageView(comicNum: 1537)
        ComicImageView(comicNum: 1302)
        ComicImageView(comicNum: 0)
    }
}
