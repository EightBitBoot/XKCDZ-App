//
//  UIComicImageViewHostingController.swift
//  XKCDZ (iOS)
//
//  Created by Adin on 5/12/22.
//

import SwiftUI

class IsAltShownWrapper: ObservableObject {
    @Published var isAltShown: Bool = false
}

struct ComicImageWithAltView: View {
    @StateObject private var metadataModelView: ComicMetadataModelView = ComicMetadataModelView();
    @ObservedObject private var isAltShownWrapper: IsAltShownWrapper = IsAltShownWrapper()
    
    let comicNum: Int
    
    var body: some View {
        let altText = metadataModelView.comicMetadata == nil ? "Alt text loading.\nTry again later." : metadataModelView.comicMetadata!.alt
        
        ComicImageView(comicNum: comicNum)
            .task {
                await metadataModelView.load(comicNum)
            }
            .alert(altText, isPresented: $isAltShownWrapper.isAltShown, actions: {})
    }
    
    func showAlt() {
        if !isAltShownWrapper.isAltShown {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            isAltShownWrapper.isAltShown.toggle()
        }
    }
}

class UIComicImageViewHostingController: UIHostingController<ComicImageWithAltView> {
    let comicNum: Int
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder:) is not implemented")
    }
    
    init(comicNum: Int) {
        self.comicNum = comicNum
        super.init(rootView: ComicImageWithAltView(comicNum: comicNum))
    }
    
    override func viewDidLoad() {
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureHandler(_:))))
    }
    
    @objc func longPressGestureHandler(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            rootView.showAlt()
        }
    }
}
