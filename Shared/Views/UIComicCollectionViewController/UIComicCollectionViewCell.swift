//
//  UIComicCollectionViewCell.swift
//  XKCDZ
//
//  Created by Adin on 5/18/22.
//

import SwiftUI
import UIKit

// NOTE(Adin): Everything commented is something I've tried to get the SwiftUI cells
//             to properly resize into their parents without needing to tap on them
//             first

//class Refresher: ObservableObject {
//    @Published var needsToRefresh: Bool = false
//}

struct ComicCollectionViewCellView: View {
    var comicNum: Int
    
//    @StateObject private var comicImageModelView: ComicImageModelView = ComicImageModelView()
    
//    @ObservedObject var refresher: Refresher = Refresher()
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
            ComicImageView(comicNum: comicNum)
            
//            if refresher.needsToRefresh {
//                EmptyView()
//                    .frame(width: 0, height: 0)
//            }
            
//            if let comicImage = comicImageModelView.image {
//                comicImage
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//            }
//            else {
//                ProgressView()
//                    .task {
//                        await comicImageModelView.load(comicNum)
//                    }
//            }
            
            Text(comicNum.description)
                .font(.subheadline)
                .padding(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)) // Padding for text within background
                .background(alignment: .center) {
                    Capsule()
                        .fill(.gray)
                    
                }
                .padding(5) // Padding for capsule within zstack
        }
        .overlay {
            Rectangle()
                .stroke(style: StrokeStyle(lineWidth: 2.0))
                .foregroundColor(.gray)
        }
    }
}

// TODO(Adin): Maybe not needed?
class UIComicCollectionViewCellHostingController: UIHostingController<ComicCollectionViewCellView> {
    var comicNum: Int
    
    init(comicNum: Int) {
        self.comicNum = comicNum
        super.init(rootView: ComicCollectionViewCellView(comicNum: comicNum))
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) isn't implemented")
    }
}

struct UIComicCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        ComicCollectionViewCellView(comicNum: 1234)
            .preferredColorScheme(.dark)
    }
}

class UIComicCollectionViewCell: UICollectionViewCell {
    func host<Content: View>(_ hostingController: UIHostingController<Content>) {
        backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        
//        More Things I've Tried:
//        NSLayoutConstraint.deactivate(hostingController.view.constraints)
//        hostingController.view.removeConstraints(hostingController.view.constraints)
        
        addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        hostingController.view.invalidateIntrinsicContentSize()
        
//        print("self.gestureRecognizers: \(self.gestureRecognizers)")
//        print("self.contentView.gestureRecognizers: \(self.contentView.gestureRecognizers)")
//        print("hostingController.view.gestureRecognizers: \(hostingController.view.gestureRecognizers)")
        
//        Things I've Tried:
//        hostingController.view.setNeedsLayout()
//|       guard let collectionViewCellView = hostingController.rootView as? ComicCollectionViewCellView
//|       else {
//|           return
//|       }
//|       collectionViewCellView.refresher.needsToRefresh.toggle()
//        self.setNeedsDisplay()
//|       hostingController.view.setNeedsLayout()
//|       hostingController.view.layoutIfNeeded()
    }
}
