//
//  UIComicCollectionViewCell.swift
//  XKCDZ
//
//  Created by Adin on 5/18/22.
//

import SwiftUI
import UIKit

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
        comicImageView.contentMode = .scaleAspectFit
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
