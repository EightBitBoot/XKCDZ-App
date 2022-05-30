//
//  UIComicPageViewController+DataSource.swift
//  XKCDZ (iOS)
//
//  Created by Adin on 5/12/22.
//

import UIKit

extension UIComicPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? UIComicImageViewHostingController
        else {
            return nil
        }
        
        let latestComicNum: Int = (ComicStore.shared.getStoredComicMetadata()?.comicNum) ?? 0
        
        if viewController.comicNum + 1 <= latestComicNum {
            return UIComicImageViewHostingController(comicNum: viewController.comicNum + 1)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? UIComicImageViewHostingController
        else {
            return nil
        }
        
        if viewController.comicNum - 1 >= 1 {
            return UIComicImageViewHostingController(comicNum: viewController.comicNum - 1)
        }
        
        return nil
    }
}
