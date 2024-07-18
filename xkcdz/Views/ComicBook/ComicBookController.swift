//
//  ComicBookController.swift
//  xkcdz
//
//  Created by Adin W-T on 7/17/24.
//

import Foundation
import UIKit

import RealmSwift

@MainActor
class ComicBookController: UIPageViewController {
    private var currentIndex: Int
    
    private var realm: Realm!
    private var metas: Results<ComicMeta>!
    
    init(firstComic: Int) {
        currentIndex = firstComic
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        realm = try! Realm(configuration: XKCDZ_SHARED_REALM_CONFIG)
        metas = realm.objects(ComicMeta.self).sorted(by: \.id)
        
        let meta = metas.first(where: { $0.id == currentIndex})!
        let firstView = ComicPageController(for: meta)
        setViewControllers([firstView], direction: .forward, animated: false)
        
        title = meta.navigationTitle
    }
}

// MARK: -- extension UIPageViewControllerDataSource

extension ComicBookController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let maxComicNum = metas.last?.id ?? 1
        if currentIndex < maxComicNum {
            // TODO(Adin): Test for and download missing metas
            return ComicPageController(for: metas.first(where: {$0.id == currentIndex + 1})!)
        }

        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentIndex > 1 {
            // TODO(Adin): Test for and download missing metas
            return ComicPageController(for: metas.first(where: {$0.id == currentIndex - 1})!)
        }

        return nil
    }
}

// MARK: -- extension UIPageViewControllerDelegate

extension ComicBookController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    )
    {
        guard 
            completed,
            let comicViewControllers = pageViewController.viewControllers as? [ComicPageController]
        else {
            return
        }
        
        currentIndex = comicViewControllers[0].meta.id
        let meta = metas.first(where: { $0.id == currentIndex })!
        title = meta.navigationTitle
    }
        
}

