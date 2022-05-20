//
//  UIComicCollectionViewLayout.swift
//  XKCDZ
//
//  Created by Adin on 5/19/22.
//

import UIKit

class UIComicCollectionViewLayout: UICollectionViewLayout {
    var settings: Settings = .default {
        didSet {
            if numColumns != columnHeights.count {
                columnHeights = [CGFloat](repeating: 0.0, count: numColumns)
                columnMembers = [[Int]](repeating: [Int](), count: numColumns)
            }
            
            
        }
    }
    
    private var columnHeights: [CGFloat] = [CGFloat](repeating: 0.0, count: Settings.default.numColumns!)
    private var columnMembers: [[Int]] = [[Int]](repeating: [Int](), count: Settings.default.numColumns!)
    private var layoutAttributesCache: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    // TODO(Adin): Temp
    private static var heightsCache: [CGFloat] = [CGFloat]()
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView
        else {
            return .zero
        }
        
        return CGSize(width: collectionView.frame.width, height: columnHeights.max()! + (2 * verticalColumnInsetSize))
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView,
              collectionView.numberOfSections > 0
        else {
            return
        }
        
        layoutAttributesCache.removeAll()
        
        // Reset column heights and members
        for columnIndex in 0..<numColumns {
            columnHeights[columnIndex] = 0.0
            columnMembers[columnIndex].removeAll()
        }
        
        // TODO(Adin): Temp
        if Self.heightsCache.isEmpty {
            for _ in 0..<collectionView.numberOfItems(inSection: 0) {
                Self.heightsCache.append(CGFloat.random(in: 200...500))
            }
                
        }
        
        let blankSpaceSize = (2 * horizontalColumnInsetSize + horizontalColumnSpacing * CGFloat(numColumns - 1))
        let itemWidth: CGFloat = (collectionView.bounds.width - blankSpaceSize) / CGFloat(numColumns)
        
        var shortestColumnIndex = 0
        var newLayoutAttribute: UICollectionViewLayoutAttributes
        var currentIndexPath: IndexPath
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            currentIndexPath = IndexPath(item: item, section: 0)
            
            newLayoutAttribute = UICollectionViewLayoutAttributes(forCellWith: currentIndexPath)
            newLayoutAttribute.frame = CGRect(x: horizontalColumnInsetSize + (itemWidth * CGFloat(shortestColumnIndex)) + (horizontalColumnSpacing * CGFloat(shortestColumnIndex)),
                                              y: columnHeights[shortestColumnIndex],
                                              width: itemWidth,
                                              height: getItemHeight(index: currentIndexPath))
            
            columnHeights[shortestColumnIndex] += newLayoutAttribute.frame.height + verticalItemSpacing
            
            columnMembers[shortestColumnIndex].append(item)
            
            layoutAttributesCache.append(newLayoutAttribute)
            
            shortestColumnIndex = columnHeights.firstIndex(of: columnHeights.min()!)!
        }
        
        // Remove the trailing spacing added by the last item in each column
        for i in 0..<columnHeights.count {
            columnHeights[i] -= verticalItemSpacing
        }
    }
    
    // TODO(Adin): Is this needed?
    // override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
    // }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesCache[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // TODO(Adin): Fix binary search for intersecting values
//        var result: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
//
//        for columnIndex in 0..<numColumns {
//            guard let lastIndexOfColumnMembers = columnMembers[columnIndex].indices.last,
//                  let foundAttributeIndex = binarySearchForIntersecting(column: columnIndex, rect: rect, start: 0, end: lastIndexOfColumnMembers)
//            else {
//                continue
//            }
//
//            for i in (0..<foundAttributeIndex).reversed() {
//                let currentAttribute = layoutAttributesCache[columnMembers[columnIndex][i]]
//                if currentAttribute.bounds.maxY < rect.minY {
//                    break
//                }
//
//                result.append(currentAttribute)
//            }
//
//            for i in foundAttributeIndex...lastIndexOfColumnMembers {
//                let currentAttribute = layoutAttributesCache[columnMembers[columnIndex][i]]
//                if currentAttribute.bounds.minY > rect.maxY {
//                    break
//                }
//
//                result.append(currentAttribute)
//            }
//        }
//
//        return result
        
        return layoutAttributesCache.filter {(attributes: UICollectionViewLayoutAttributes) -> Bool in
            return rect.intersects(attributes.frame)
        }
    }
    
//    func binarySearchForIntersecting(column: Int, rect: CGRect, start: Int, end: Int) -> Int? {
//        if end < start || columnMembers[column].isEmpty {
//            return nil
//        }
//
//        let midIndex = (start + end) / 2
//        let midAttribute = layoutAttributesCache[columnMembers[column][midIndex]]
//
//        if midAttribute.bounds.intersects(rect) {
//            return midIndex
//        }
//        else if midAttribute.bounds.maxY < rect.minY {
//            return binarySearchForIntersecting(column: column, rect: rect, start: midIndex + 1, end: end)
//        }
//        else {
//            return binarySearchForIntersecting(column: column, rect: rect, start: start, end: midIndex - 1)
//        }
//    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView
        else {
            return false
        }
        
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    // TOOD(Adin): Is this needed?
    // override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    //    return nil
    // }
    
    func getItemHeight(index: IndexPath) -> CGFloat {
        // TODO(Adin): Make this real
        return Self.heightsCache[index.item]
    }
    
}

// MARK: - Settings

extension UIComicCollectionViewLayout {
    struct Settings {
        var horizontalColumnInsetSize: CGFloat?
        var verticalColumnInsetSize: CGFloat?
        var horizontalColumnSpacing: CGFloat?
        var verticalItemSpacing: CGFloat?
        var numColumns: Int?
        
        static let `default` = Settings(horizontalColumnInsetSize: 10.0, verticalColumnInsetSize: 10.0, horizontalColumnSpacing: 15.0, verticalItemSpacing: 10.0, numColumns: 1)
    }
    
    var horizontalColumnInsetSize: CGFloat {
        if let val = settings.horizontalColumnInsetSize {
            return max(0.0, val)
        }
        
        return Settings.default.horizontalColumnInsetSize!
    }
    
    var verticalColumnInsetSize: CGFloat {
        if let val = settings.verticalColumnInsetSize {
            return max(0.0, val)
        }
        
        return Settings.default.verticalColumnInsetSize!
    }
    
    
    var horizontalColumnSpacing: CGFloat {
        if let val = settings.horizontalColumnSpacing {
            return max(0.0, val)
        }
        
        return Settings.default.horizontalColumnSpacing!
    }
    
    
    var verticalItemSpacing: CGFloat {
        if let val = settings.verticalItemSpacing {
            return max(0.0, val)
        }
        
        return Settings.default.verticalItemSpacing!
    }
    
    
    var numColumns: Int {
        if let val = settings.numColumns {
            return max(1, val)
        }
        
        return Settings.default.numColumns!
    }
}
