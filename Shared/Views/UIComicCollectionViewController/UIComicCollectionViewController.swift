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
    
    var dataSource: DataSource!
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        
        // The comic grid view isn't going to be reorganizable
//        installsStandardGestureForInteractiveMovement = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) isn't implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellRegistration = UICollectionView.CellRegistration<UIComicCollectionViewCell, Int>(handler: cellRegistrationHandler(_:_:_:))
        dataSource = DataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Int) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        applyTestSnapshot()
        
        collectionView.dataSource = dataSource
    }
    
    
    func cellRegistrationHandler(_ cell: UIComicCollectionViewCell, _ indexPath: IndexPath, _ itemIdentifier: Int) {
        for subview in cell.subviews {
            subview.removeFromSuperview()
        }
        
//        cell.layer.shouldRasterize = true
//        cell.layer.rasterizationScale = UIScreen.main.scale
        
        cell.host(UIHostingController(rootView: ComicCollectionViewCellView(comicNum: itemIdentifier)))
    }
    
    func applyTestSnapshot() {
        var snapshot: Snapshot = Snapshot()
        
        snapshot.appendSections([0])
        // TODO(Adin): This crashes if the ComicStore is empty
        snapshot.appendItems([Int]((1...ComicStore.getLatestStoredMetadataBlocking()!.num).reversed()))
        
        dataSource.apply(snapshot)
    }
}

extension UIComicCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 300)
    }
}
