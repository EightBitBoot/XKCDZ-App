//
//  UIComicCollectionViewController.swift
//  XKCDZ
//
//  Created by Adin on 5/18/22.
//

import UIKit
import SwiftUI

class UIComicCollectionViewController: UICollectionViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Int>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Int>
    typealias Cell = UIComicCollectionViewCell
    
    var dataSource: DataSource!
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) isn't implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UIComicCollectionViewLayout = UIComicCollectionViewLayout()
        layout.settings = UIComicCollectionViewLayout.Settings(numColumns: 2)
        
//        // TODO(Adin): Is this needed?
//        // Remove old, default collection view from super view
//        // before adding new one
//        collectionView.removeFromSuperview()
        
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceVertical = true
        collectionView.indicatorStyle = .white
        collectionView.delegate = self
        
        let cellRegistration = UICollectionView.CellRegistration<Cell, Int>(handler: cellRegistrationHandler(_:_:_:))
        dataSource = DataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Int) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        applyTestSnapshot()
        
        collectionView.dataSource = dataSource
        
        self.view.addSubview(collectionView)
    }
    
    private func cellRegistrationHandler(_ cell: Cell, _ indexPath: IndexPath, _ itemIdentifier: Int) {
        cell.currentComicNum = itemIdentifier
        
        // Keep a weak reference to cell so the closures won't keep
        // cell loaded if the CollectionView is unloaded before
        // they finish
        weak var weakCell = cell

        Task {
            guard weakCell != nil,
                  let comicImage = await ComicStore.shared.getComicImage(for: itemIdentifier, ofSize: .Default)
            else {
                return
            }

            DispatchQueue.main.async {
                guard let cell = weakCell,
                      let cellComicNum = cell.currentComicNum
                else {
                    return
                }

                if cellComicNum == itemIdentifier {
                    cell.comicImageView.image = comicImage
                    cell.comicNumLabel.text = itemIdentifier.description
                }
            }
        }
    }
    
    private func applyTestSnapshot() {
        var snapshot: Snapshot = Snapshot()
        
        snapshot.appendSections([0])
        // TODO(Adin): This crashes if the ComicStore is empty
        snapshot.appendItems([Int]((1...ComicStore.shared.getStoredComicMetadata()!.comicNum).reversed()))
        
        dataSource.apply(snapshot)
    }
}
