//
//  UIComicPageViewController.swift
//  XKCDZ (iOS)
//
//  Created by Adin on 5/11/22.
//

import UIKit

class UIComicPageViewController: UIPageViewController {
    typealias Coordinator = UIComicPageViewControllerRepresentatble.Coordinator
    
    init(initialComicNum: Int, coordinator: Coordinator) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
        self.delegate = coordinator
        self.dataSource = self
        
        setViewControllers([UIComicImageViewHostingController(comicNum: initialComicNum)], direction: .forward, animated: true)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) isn't implemented")
    }
}
