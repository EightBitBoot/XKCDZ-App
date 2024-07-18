//
//  ContextMenuTestViewController.swift
//  xkcdz
//
//  Created by Adin W-T on 7/4/23.
//

import UIKit

class TestViewController: UIViewController {
    var imageView: UIImageView!
    
//    override func loadView() {
//        imageView = UIImageView()
//        view = imageView
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        let image = UIImage(named: "test_comic_square")!
        imageView.image = image
        
        let contextInteraction = UIContextMenuInteraction(delegate: self)
        imageView.addInteraction(contextInteraction)
        imageView.isUserInteractionEnabled = true
        
        view.addSubview(imageView)
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        addIVConstraints()
        
        print("View did load")
        print(imageView.frame.size)
        print(imageView.intrinsicContentSize)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("View will appear")
        print(imageView.frame.size)
        print(imageView.intrinsicContentSize)
    }
    
    func addIVConstraints() {
        guard let image = imageView.image else { return }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if image.size.width >= image.size.height {
            let aspectRatio = image.size.height / image.size.width

            imageView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true

            imageView.addConstraint(NSLayoutConstraint(
                item: imageView!,
                attribute: .height,
                relatedBy: .equal,
                toItem: imageView!,
                attribute: .width,
                multiplier: aspectRatio,
                constant: 0.0
            ))
        }
        else {
            let aspectRatio = image.size.width / image.size.height

            imageView.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor).isActive = true
            
            imageView.addConstraint(NSLayoutConstraint(
                item: imageView!,
                attribute: .width,
                relatedBy: .equal,
                toItem: imageView!,
                attribute: .height,
                multiplier: aspectRatio,
                constant: 0.0
            ))
        }
        
        imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
//        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
//
//        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
}

extension TestViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            let aAction = UIAction(title: "A", image: UIImage(systemName: "a.circle.fill")) { [weak self] action in
                guard let self = self
                else {
                    print("Goodbye self a")
                    return
                }
                
                self.a()
            }
            
            let bAction = UIAction(title: "B", image: UIImage(systemName: "b.circle.fill")) { [weak self] action in
                guard let self = self
                else {
                    print("Goodbye self b")
                    return
                }
                
                self.b()
            }
            
            let cAction = UIAction(title: "C", image: UIImage(systemName: "b.circle.fill")) { [weak self] action in
                guard let self = self
                else {
                    print("Goodbye self c")
                    return
                }
                
                self.c()
            }
            
            return UIMenu(title: "Soup", children: [aAction, bAction, cAction])
        })
    }
    
    func a() {
        print("a")
    }
    
    func b() {
        print("b")
    }
    
    func c() {
        print("C")
    }
}
