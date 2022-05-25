//
//  UIComicCollectionViewHostingController.swift
//  XKCDZ
//
//  Created by Adin on 5/19/22.
//

import SwiftUI

struct UIComicCollectionViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIComicCollectionViewController
    typealias Context = UIViewControllerRepresentableContext<Self>
    
    func makeUIViewController(context: Context) -> UIComicCollectionViewController {
        return UIComicCollectionViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIComicCollectionViewController, context: Context) {
    }
    
    static func dismantleUIViewController(_ uiViewController: UIComicCollectionViewController, coordinator: Coordinator) {
    }
}
