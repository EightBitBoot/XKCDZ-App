//
//  ComicFullscreenView.swift
//  XKCDZ
//
//  Created by Adin on 4/13/22.
//

import SwiftUI
import Combine

struct ComicFullscreenView: View {
    @StateObject private var comicMetadataModelView: ComicMetadataModelView = ComicMetadataModelView()
    
    @State var currentComicNum: Int
    
    var body: some View {
        let navigationTitle: String = comicMetadataModelView.comicMetadata == nil ? currentComicNum.description : "\(currentComicNum.description) - \(comicMetadataModelView.comicMetadata!.safeTitle)"
        
        UIComicPageViewControllerRepresentatble(currentComicNum: $currentComicNum)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await comicMetadataModelView.load(currentComicNum)
            }
            .onReceive(Just(currentComicNum)) { newValue in
                Task {
                    await comicMetadataModelView.load(newValue)
                }
            }
    }
}

struct ComicFullscreenView_Previews: PreviewProvider {
    static var previews: some View {
        ComicFullscreenView(currentComicNum: 110)
    }
}
