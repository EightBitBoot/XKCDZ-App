//
//  ComicPageView.swift
//  xkcdz
//
//  Created by Adin W-T on 7/17/24.
//

import Foundation
import UIKit

// TODO(Adin): Fill out with real content

@MainActor
class ComicPageViewController: UIViewController {
    let meta: ComicMeta
    private var activityIndicator: UIActivityIndicatorView!
    private var imageView: UIImageView!
    private var scrollView: UIScrollView!
    
    init(for meta: ComicMeta) {
        self.meta = meta
        print("ComicPageViewController init for: \(meta.id)")
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
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ComicPageViewController.showAltPopup))
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
        
        imageView = UIImageView(frame: scrollView.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(imageView)
        
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
            
//            print("Data Size: \(imageData.count)")
            let image = UIImage(data: imageData)!
            imageView.image = await image.byPreparingForDisplay()
            
            activityIndicator.stopAnimating()
            scrollView.isScrollEnabled = true
            scrollView.isHidden = false
            
//            print("Done: \(meta.id)")
        }
    }
    
    @objc func showAltPopup() {
        print("ShowAltPopup")
        let alertController = UIAlertController(title: "Alt", message: meta.alt, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alertController, animated: true)
    }
}

extension ComicPageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
