//
//  UIComicImageViewHostingController.swift
//  XKCDZ (iOS)
//
//  Created by Adin on 5/12/22.
//

import SwiftUI

struct ComicImageViewLongPressWrapper: View {
    @StateObject private var metadataModelView: ComicMetadataModelView = ComicMetadataModelView();
    @State private var isAltShown: Bool = false
    
    let comicNum: Int
    
    var body: some View {
        let altText = metadataModelView.comicMetadata == nil ? "Alt text loading.\nTry again later." : metadataModelView.comicMetadata!.alt
        
        ComicImageView(comicNum: comicNum)
            .task {
                await metadataModelView.load(comicNum)
            }
            .onLongPressGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                isAltShown.toggle()
            }
            .alert(altText, isPresented: $isAltShown, actions: {})
    }
}

class UIComicImageViewHostingController: UIHostingController<ComicImageViewLongPressWrapper> {
    let comicNum: Int
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder:) is not implemented")
    }
    
    init(comicNum: Int) {
        self.comicNum = comicNum
        super.init(rootView: ComicImageViewLongPressWrapper(comicNum: comicNum))
    }
}
