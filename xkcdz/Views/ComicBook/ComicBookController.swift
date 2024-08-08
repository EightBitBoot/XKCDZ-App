//
//  ComicBookController.swift
//  xkcdz
//
//  Created by Adin W-T on 7/17/24.
//

import Foundation
import UIKit
import os

import RealmSwift

@MainActor
class ComicBookController: UIPageViewController {
    private var currentIndex: Int

    private var realm: Realm!
    private var metas: Results<ComicMeta>!

    private var hideStatusbar = false

    private var toggleBarsGestureRecognizer: UITapGestureRecognizer!
//    private static var logger: os.Logger = os.Logger(
//        subsystem: Bundle.main.bundleIdentifier!,
//        category: String(describing: ComicBookController.self)
//    )

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
        self.navigationItem.backButtonDisplayMode = .minimal
        self.navigationItem.largeTitleDisplayMode = .always

        toggleBarsGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleBars))
        view.addGestureRecognizer(toggleBarsGestureRecognizer)

        let randomButton = UIBarButtonItem(image: UIImage(systemName: "shuffle"), style: .plain, target: self, action: #selector(showRandomComic))
        self.toolbarItems = [randomButton]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.isToolbarHidden = false

        self.navigationController?.navigationBar.alpha = 1.0
        self.navigationController?.toolbar.alpha = 1.0
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.isToolbarHidden = true

        // TODO(Adin): Fix this animation so it feels better (remove? / modify?)
        if (self.navigationController?.navigationBar.alpha ?? 1.0) < 1.0 {
            UIView.animate(withDuration: 0.2, delay: 0.0, animations: {
                self.navigationController?.navigationBar.alpha = 1.0
            })
        }
        self.navigationController?.toolbar.alpha = 1.0
    }

    override var prefersStatusBarHidden: Bool {
        return hideStatusbar
    }

    @objc private func toggleBars(_ sender: Any) {
        let newNavAlpha = abs((self.navigationController?.navigationBar.alpha ?? 0.0) - 1.0)
        let newToolAlpha = abs((self.navigationController?.toolbar.alpha ?? 0.0) - 1.0)
        self.hideStatusbar.toggle()
        // Note(Adin): This is slightly counter-intuitive: when the animation is to _hide_ the elements
        //             (hideStatusbar == true), easing in means "start fast then fall off", and - for
        //             showing the elements - easing out means "start slow then speed up"
        let options: UIView.AnimationOptions = (self.hideStatusbar ? [.curveEaseOut] : [.curveEaseOut])

        UIView.animate(
            withDuration: 0.2, // Apple's Photos app uses 0.25 (Found through trial and error)
            delay: 0.0,        // Apple's Photos app uses 0.30 (Found through trial and error)
            options: options,
            animations: {
                // IMPORTANT(Adin): setNeedsStatusBarAppearanceUpdate _NEEDS_ to be first, otherwise
                //                  the animation appears buggy and the bars' alpha is always set to
                //                  1.0
                self.navigationController?.setNeedsStatusBarAppearanceUpdate()
                self.navigationController?.navigationBar.alpha = newNavAlpha
                self.navigationController?.toolbar.alpha = newToolAlpha
            }
//            },
//            completion: { _ in
//                Self.logger.debug("NavBar Alpha: \(self.navigationController!.navigationBar.alpha), ToolBar Alpha: \(self.navigationController!.toolbar.alpha)")
//                Self.logger.debug("Prefers Status Bar Hidden: \(self.prefersStatusBarHidden)")
//            }
        )
    }

    @objc private func showRandomComic(_ sender: Any) {
        let alertController = UIAlertController(title: "Random Comics", message: "Get ya random comics here!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alertController, animated: true)
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

