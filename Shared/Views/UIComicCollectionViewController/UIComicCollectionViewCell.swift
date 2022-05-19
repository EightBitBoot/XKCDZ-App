//
//  UIComicCollectionViewCell.swift
//  XKCDZ
//
//  Created by Adin on 5/18/22.
//

import SwiftUI
import UIKit

struct ComicCollectionViewCellView: View {
    var comicNum: Int
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
            ComicImageView(comicNum: comicNum)
            
            Text(comicNum.description)
                .font(.subheadline)
                .padding(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)) // Padding for text within background
                .background(alignment: .center) {
                    Capsule()
                        .fill(.gray)
                    
                }
                .padding(5) // Padding for capsule within zstack
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
        addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
