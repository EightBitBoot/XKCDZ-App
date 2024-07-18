//
//  ComicShelfCell.swift
//  xkcdz
//
//  Created by Adin W-T on 7/10/23.
//

import UIKit

// MARK: -- ComicShelfCell

class ComicShelfCell: UICollectionViewCell {
    var comicId: Int!
    
    func getDefaultLoadingConfiguration(for comicNum: Int) -> ComicShelfContentConfiguration {
        return ComicShelfContentConfiguration(forNum: comicNum, isLoading: true)
    }
}

// MARK: -- ComicShelfContentView

class ComicShelfContentView: UIView, UIContentView {
    private static let marginSize: CGFloat = 5.0
    
    let imageView = UIImageView()
    let numberLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView()
    
    var configuration: UIContentConfiguration {
        didSet {
            configure(with: configuration)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: imageView.intrinsicContentSize.width + 2 * ComicShelfContentView.marginSize,
                      height: imageView.intrinsicContentSize.height + 2 * ComicShelfContentView.marginSize)
    }
    
    init(_ contentConfiguration: UIContentConfiguration) {
        configuration = contentConfiguration
        super.init(frame: .zero)
        
        self.backgroundColor = .lightGray
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // TODO(Adin): Make a custom label subclass that has text insets
        numberLabel.textColor = .white
        numberLabel.backgroundColor = .gray
        // TODO(Adin): Make corner radius dynamic to form a pill shape
        //             radius = shortestEdgeLength / 2
        numberLabel.layer.masksToBounds = true
        numberLabel.layer.cornerRadius = 6
        numberLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        imageView.addSubview(numberLabel)
        
        self.layoutMargins = UIEdgeInsets(top: ComicShelfContentView.marginSize,
                                          left: ComicShelfContentView.marginSize,
                                          bottom: ComicShelfContentView.marginSize,
                                          right: ComicShelfContentView.marginSize)
        
        imageView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        
        numberLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -ComicShelfContentView.marginSize).isActive = true
        numberLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -ComicShelfContentView.marginSize).isActive = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        configure(with: contentConfiguration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with configuration: UIContentConfiguration) {
        guard let configuration = configuration as? ComicShelfContentConfiguration else { return }
        
        if configuration.isLoading {
            imageView.isHidden = true
            numberLabel.text = String(configuration.comicNum)
            activityIndicator.startAnimating()
        }
        else {
            numberLabel.text = String(configuration.comicNum)
            imageView.image = configuration.comicImage
            activityIndicator.stopAnimating()
            imageView.isHidden = false
        }
    }
}

// MARK: -- ComicShelfContentConfiguration

class ComicShelfContentConfiguration: UIContentConfiguration {
    let comicNum: Int
    let comicImage: UIImage
    let isLoading: Bool
    
    private init() {
        comicNum = 0
        comicImage = UIImage()
        isLoading = false
    }
    
    init(forNum num: Int, withImage image: UIImage) {
        comicNum = num
        comicImage = image
        isLoading = false
    }
    
    fileprivate init(forNum num: Int, isLoading loading: Bool) {
        comicNum = num
        comicImage = UIImage()
        isLoading = loading
    }
    
    func makeContentView() -> UIView & UIContentView {
        return ComicShelfContentView(self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
