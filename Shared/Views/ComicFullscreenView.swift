//
//  ComicFullscreenView.swift
//  XKCDZ
//
//  Created by Adin on 4/13/22.
//

import SwiftUI

struct ComicFullscreenView: View {
    @StateObject var comicMetadataModelView: ComicMetadataModelView = ComicMetadataModelView()
    @State var isAltShown: Bool = false
    var comicNum: Int
    
    var body: some View {
        let navigationTitle: String = comicMetadataModelView.comicMetadata == nil ? comicNum.description : "\(comicNum.description) - \(comicMetadataModelView.comicMetadata!.safe_title)"
        let altText: String = comicMetadataModelView.comicMetadata == nil ? "Loading alt text..." : comicMetadataModelView.comicMetadata!.alt
        
        ComicImageView(comicNum: comicNum)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await comicMetadataModelView.load(comicNum)
            }
            .onLongPressGesture {
                self.isAltShown.toggle()
            }
            .alert(altText, isPresented: $isAltShown, actions: {})
    }
}

struct ComicFullscreenView_Previews: PreviewProvider {
    static var previews: some View {
        ComicFullscreenView(comicNum: 110)
    }
}
