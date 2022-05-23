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
        for subview in cell.subviews {
            subview.removeFromSuperview()
        }

        cell.host(UIHostingController(rootView: ComicCollectionViewCellView(comicNum: itemIdentifier)))
    }
    
    private func applyTestSnapshot() {
        var snapshot: Snapshot = Snapshot()
        
        snapshot.appendSections([0])
        // TODO(Adin): This crashes if the ComicStore is empty
        snapshot.appendItems([Int]((1...ComicStore.getLatestStoredMetadataBlocking()!.num).reversed()))
        
        dataSource.apply(snapshot)
    }
}
