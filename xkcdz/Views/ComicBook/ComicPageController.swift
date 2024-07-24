//
//  ComicPageController.swift
//  xkcdz
//
//  Created by Adin W-T on 7/17/24.
//

import Foundation
import UIKit

// TODO(Adin): Fill out with real content

@MainActor
class ComicPageController: UIViewController {
    let meta: ComicMeta
    private var activityIndicator: UIActivityIndicatorView!
    private var comicPaneView: ComicPaneView!
    private var scrollView: UIScrollView!
    
    init(for meta: ComicMeta) {
        self.meta = meta
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder:) has not been implemented")
    }
    
    // TODO(Adin): Shrink scroll view to fit image so there
    //             aren't black borders when zooming in
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showAltPopup))
        view.addGestureRecognizer(longPressRecognizer)
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.isScrollEnabled = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        scrollView.isHidden = true
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scrollView)
        
        comicPaneView = ComicPaneView(frame: scrollView.bounds)
        comicPaneView.contentMode = .scaleAspectFit
        comicPaneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(comicPaneView)
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        activityIndicator.startAnimating()
        
        Task {
            var imageData: Data!
            do {
                imageData = try await ComicShop.shared.getLargestImage(for: meta.id)
            }
            catch {
                print(error)
                fatalError("Goodbye")
            }
            
//            comicPaneView.comicImage = await (UIImage(data: imageData)!.byPreparingForDisplay())!
            comicPaneView.comicImage = UIImage(data: imageData)

            activityIndicator.stopAnimating()
            scrollView.isScrollEnabled = true
            scrollView.isHidden = false
        }
    }
    
    @objc func showAltPopup() {
        let alertController = UIAlertController(title: "Alt", message: meta.alt, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alertController, animated: true)
    }
}

extension ComicPageController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return comicPaneView
    }
}
