//
//  ComicShelfController.swift
//  xkcdz
//
//  Created by Adin W-T on 6/11/23.
//

import UIKit
import RealmSwift

@MainActor
class ComicShelfController: UICollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, Int>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Int>
    
    private var realm: Realm!
    private var dataSource: DataSource!
    private var comicMetas: Results<ComicMeta>!
    
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .systemBackground
        
        let cellRegistration = UICollectionView.CellRegistration<ComicShelfCell, Int>(handler: registrationHandler)
        
        realm = try! Realm(configuration: XKCDZ_SHARED_REALM_CONFIG)
        comicMetas = realm.objects(ComicMeta.self).sorted(by: \.id)
        dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Int) in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        collectionView.collectionViewLayout = layout
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshComics), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        applyInitialSnapshot()
    }
    
    
    func registrationHandler(cell: UICollectionViewCell, indexPath: IndexPath, item: Int) {
        Task { [weak self] in
            
            guard let cell = cell as? ComicShelfCell else { return }
            cell.comicId = item
            let configuration = cell.getDefaultLoadingConfiguration(for: item)
            cell.contentConfiguration = configuration

            var imageData: Data? = nil
            do {
                imageData = try await ComicShop.shared.getLargestImage(for: item)
            }
            catch ComicShop.ComicShopDownloadError.HTTPResponseCodeError(let code) where code == 403 || code == 404 {
                if cell.comicId == item {
                    let image = UIImage(systemName: "exclamationmark.circle.fill")!
                    let configuration = ComicShelfContentConfiguration(forNum: item, withImage: image)
                    cell.contentConfiguration = configuration
                }
            }
            catch {
                print(error)
                fatalError("Goodbye")
            }
            
            let image = (await UIImage(data: imageData!)?.byPreparingThumbnail(ofSize: CGSize(width: 300.0, height: 300.0)))!
            
            guard let _ = self else { return }
            
            if cell.comicId == item {
                let configuration = ComicShelfContentConfiguration(forNum: item, withImage: image)
                cell.contentConfiguration = configuration
            }
        }
    }
    
}

// MARK: -- extension Data Source

extension ComicShelfController {
    func applyInitialSnapshot() {
        Task { [weak self] in
            var snapshot = Snapshot()
            do {
                try await ComicShop.shared.downloadMeta() // Downloads latest meta
            }
            catch {
                print(error)
                fatalError("Goodbye")
            }
            self?.realm.refresh()
            let latestMetaNum = self?.comicMetas.last?.id ?? 1
            print(latestMetaNum)
            
            snapshot.appendSections([0])
            snapshot.appendItems(Array(stride(from: latestMetaNum, to: 0, by: -1)), toSection: 0)
            
            if let self = self {
                await dataSource.apply(snapshot)
            }
        }
    }
    
    // TODO(Adin): Stop refresh control from displaying between top comics
    //             and keep comics below while refreshing
    @objc func refreshComics() {
        Task {
            let oldLatestNum = comicMetas.last?.id ?? 1
            do {
                try await ComicShop.shared.downloadMeta()
            }
            catch {
                print(error)
                fatalError("Goodbye")
            }
            let newLatestNum = comicMetas.last?.id ?? 1
            
            if newLatestNum > oldLatestNum {
                var snapshot = Snapshot()
                snapshot.appendSections([0])
                snapshot.appendItems(Array(stride(from: newLatestNum, to: 0, by: -1)), toSection: 0)
                collectionView.refreshControl?.endRefreshing()
                await dataSource.apply(snapshot, animatingDifferences: true)
                
                return
            }
            
            collectionView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: -- extension UICollectionViewDelegate

extension ComicShelfController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let comicsPageViewController = ComicBookController(firstComic: dataSource.itemIdentifier(for: indexPath) ?? 1)
        print("IndexPath Item: \(indexPath.item)")
        navigationController?.pushViewController(comicsPageViewController, animated: true)
    }
}
