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
    var comicImageView: UIImageView = UIImageView()
    var comicNumLabel: UILabel = UILabel()
    
    var currentComicNum: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        // This appears to be the default value but apple's example sets this explicitly
        self.autoresizesSubviews = true
        self.backgroundColor = .lightGray
        
        comicImageView.frame = self.bounds
        comicImageView.contentMode = .scaleAspectFill
        comicImageView.clipsToBounds = true
        comicImageView.translatesAutoresizingMaskIntoConstraints = false
        comicImageView.backgroundColor = .clear
        
        self.addSubview(comicImageView)
        
        NSLayoutConstraint.activate([
            comicImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
            comicImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
            comicImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2),
            comicImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -2)
        ])
        
        
        comicNumLabel.translatesAutoresizingMaskIntoConstraints = false
        comicNumLabel.backgroundColor = .gray
        
        comicImageView.addSubview(comicNumLabel)
        
        NSLayoutConstraint.activate([
            comicNumLabel.rightAnchor.constraint(equalTo: comicImageView.rightAnchor, constant: -4),
            comicNumLabel.bottomAnchor.constraint(equalTo: comicImageView.bottomAnchor, constant: -4)
        ])
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) isn't implemented")
    }
    
    override func prepareForReuse() {
        currentComicNum = nil
        comicImageView.image = nil
        comicNumLabel.text = nil
    }
}
