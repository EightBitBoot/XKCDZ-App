//
//  ViewController.swift
//  xkcdz
//
//  Created by Adin W-T on 6/11/23.
//

import UIKit
import RealmSwift

class ComicsViewController: UICollectionViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Int>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Int>
    
    var realm: Realm!
    var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Int>(handler: registrationHandler)
        
        realm = try! Realm(configuration: XKCDZ_SHARED_REALM_CONFIG)
        dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Int) in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        collectionView.collectionViewLayout = layout
        
        applyInitialSnapshot()
    }
    
    func applyInitialSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
//        snapshot.appendItems([0, 1, 2], toSection: 0)
        snapshot.appendItems([0, 1, 2], toSection: 0)
        dataSource.apply(snapshot)
    }
    
    func registrationHandler(cell: UICollectionViewCell, indexPath: IndexPath, item: Int) {
        let imageName: String
        switch item {
            case 0:
                imageName = "test_comic_square"
            case 1:
                imageName = "test_comic_tall"
            default:
                imageName = "xkcdz_comic_error"
        }
        
        let image = UIImage(named: imageName)!
        let configuration = ComicContentViewConfiguration(forNum: item, withImage: image)
        cell.contentConfiguration = configuration
    }
}
