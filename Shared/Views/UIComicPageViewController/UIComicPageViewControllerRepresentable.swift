//
//  UIComicPageViewRepresentable.swift
//  XKCDZ (iOS)
//
//  Created by Adin on 5/11/22.
//

import SwiftUI

struct UIComicPageViewControllerRepresentatble: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIComicPageViewController
    typealias Context = UIViewControllerRepresentableContext<Self>
    
    @Binding var currentComicNum: Int
    
    // TODO(Adin): Add currently displayed comic number binding
    
    func makeUIViewController(context: Context) -> UIComicPageViewController {
        return UIComicPageViewController(initialComicNum: currentComicNum, coordinator: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: UIComicPageViewController, context: Context) {
    }
    
    static func dismantleUIViewController(_ uiViewController: UIComicPageViewController, coordinator: Coordinator) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDelegate {
        var parentView: UIComicPageViewControllerRepresentatble
        
        init(_ parent: UIComicPageViewControllerRepresentatble) {
            self.parentView = parent
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted: Bool) {
            if transitionCompleted {
                guard pageViewController.viewControllers != nil,
                      !pageViewController.viewControllers!.isEmpty,
                      let currentViewController = pageViewController.viewControllers![0] as? UIComicImageViewHostingController
                else {
                    return
                }
                
                parentView.currentComicNum = currentViewController.comicNum
            }
        }
    }
}

struct UIComicPageViewControllerRepresentable_Previews: PreviewProvider {
    @State static var currentComicNum: Int = 1234
    
    static var previews: some View {
        UIComicPageViewControllerRepresentatble(currentComicNum: $currentComicNum)
            .preferredColorScheme(.dark)
        UIComicPageViewControllerRepresentatble(currentComicNum: $currentComicNum)
    }
}
