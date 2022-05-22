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
            if oldValue != settings {
                self.invalidateLayout()
            }
            
            if oldValue.numColumns != settings.numColumns {
                columnHeights = [CGFloat](repeating: 0.0, count: settings.numColumns)
                columnMembers = [[Int]](repeating: [Int](), count: settings.numColumns)
            }
        }
    }
    
    private var columnHeights: [CGFloat] = [CGFloat](repeating: 0.0, count: Settings.default.numColumns)
    private var columnMembers: [[Int]] = [[Int]](repeating: [Int](), count: Settings.default.numColumns)
    private var layoutAttributesCache: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    // TODO(Adin): Temp
    private static var heightsCache: [CGFloat] = [CGFloat]()
    
    convenience override init() {
        self.init(settings: nil)
    }
    
    init(settings: UIComicCollectionViewLayout.Settings?) {
        super.init()
        
        if let settings = settings {
            self.settings = settings
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) isn't implemented")
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView
        else {
            return .zero
        }
        
        return CGSize(width: collectionView.frame.width, height: columnHeights.max()! + (2 * settings.verticalColumnInset))
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView,
              collectionView.bounds.size != .zero,
              collectionView.numberOfSections > 0
        else {
            return
        }
        
        layoutAttributesCache.removeAll()
        
        // Reset column heights and members
        for columnIndex in 0..<settings.numColumns {
            // Set the column at columnIndex to 0
            columnHeights[columnIndex] = 0.0
            // Remove all column members of the column columnIndex
            columnMembers[columnIndex].removeAll()
        }
        
        // TODO(Adin): Temp
        if Self.heightsCache.isEmpty {
            for _ in 0..<collectionView.numberOfItems(inSection: 0) {
                Self.heightsCache.append(CGFloat.random(in: 200...500))
            }
                
        }
        
        // Total width of all horizontal empty space (insets, and column spacings)
        let horizontalEmptySpace = (2 * settings.horizontalColumnInset) + (settings.horizontalColumnSpacing * CGFloat(settings.numColumns - 1))
        // Width of each item
        let itemWidth: CGFloat = (collectionView.bounds.width - horizontalEmptySpace) / CGFloat(settings.numColumns)
        
        var shortestColumnIndex = 0
        var currentLayoutAttribute: UICollectionViewLayoutAttributes
        var currentIndexPath: IndexPath
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            currentIndexPath = IndexPath(item: item, section: 0)
            
            currentLayoutAttribute = UICollectionViewLayoutAttributes(forCellWith: currentIndexPath)
            currentLayoutAttribute.frame = CGRect(x: settings.horizontalColumnInset + (itemWidth * CGFloat(shortestColumnIndex)) + (settings.horizontalColumnSpacing * CGFloat(shortestColumnIndex)),
                                                  y: columnHeights[shortestColumnIndex],
                                                  width: itemWidth,
                                                  height: getItemHeight(index: currentIndexPath))
            
            columnHeights[shortestColumnIndex] += currentLayoutAttribute.frame.height + settings.verticalItemSpacing
            
            columnMembers[shortestColumnIndex].append(item)
            
            layoutAttributesCache.append(currentLayoutAttribute)
            
            // NOTE: This is linear to settings.numColumns
            shortestColumnIndex = columnHeights.firstIndex(of: columnHeights.min()!)!
        }
        
        // Remove the trailing spacing added by the last item in each column
        for i in 0..<columnHeights.count {
            columnHeights[i] -= settings.verticalItemSpacing
        }
    }
    
    // TODO(Adin): Is this needed?
    // override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
    // }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesCache[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()

        for columnIndex in 0..<settings.numColumns {
            guard let lastIndexOfColumnMembers = columnMembers[columnIndex].indices.last,
                  let foundAttributeIndex = binarySearchForIntersecting(column: columnIndex, rect: rect, start: 0, end: lastIndexOfColumnMembers)
            else {
                continue
            }

            for i in (0..<foundAttributeIndex).reversed() {
                let currentAttribute = layoutAttributesCache[columnMembers[columnIndex][i]]
                if currentAttribute.frame.maxY < rect.minY {
                    break
                }

                result.append(currentAttribute)
            }

            for i in foundAttributeIndex...lastIndexOfColumnMembers {
                let currentAttribute = layoutAttributesCache[columnMembers[columnIndex][i]]
                if currentAttribute.frame.minY > rect.maxY {
                    break
                }

                result.append(currentAttribute)
            }
        }

        return result
    }
    
    func binarySearchForIntersecting(column: Int, rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start || columnMembers[column].isEmpty {
            return nil
        }

        let midIndex = (start + end) / 2
        let midAttribute = layoutAttributesCache[columnMembers[column][midIndex]]

        if midAttribute.frame.intersects(rect) {
            return midIndex
        }
        else if midAttribute.frame.maxY < rect.minY {
            return binarySearchForIntersecting(column: column, rect: rect, start: midIndex + 1, end: end)
        }
        else {
            return binarySearchForIntersecting(column: column, rect: rect, start: start, end: midIndex - 1)
        }
    }
    
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
    
    // TODO(Adin): Make this get the real, adjusted height
    func getItemHeight(index: IndexPath) -> CGFloat {
        return Self.heightsCache[index.item]
    }
    
}

// MARK: - Settings

extension UIComicCollectionViewLayout {
    struct Settings: Equatable {
        private var horizontalColumnInset_val: CGFloat? = nil
        private var verticalColumnInset_val: CGFloat? = nil
        private var horizontalColumnSpacing_val: CGFloat? = nil
        private var verticalItemSpacing_val: CGFloat? = nil
        private var numColumns_val: Int? = nil
        
        static let `default` = Settings(horizontalColumnInset: 10.0, verticalColumnInset: 10.0, horizontalColumnSpacing: 15.0, verticalItemSpacing: 10.0, numColumns: 1)
        
        init(horizontalColumnInset: CGFloat? = nil, verticalColumnInset: CGFloat? = nil, horizontalColumnSpacing: CGFloat? = nil, verticalItemSpacing: CGFloat? = nil, numColumns: Int? = nil) {
            self.horizontalColumnInset_val = horizontalColumnInset
            self.verticalColumnInset_val = verticalColumnInset
            self.horizontalColumnSpacing_val = horizontalColumnSpacing
            self.verticalItemSpacing_val = verticalItemSpacing
            self.numColumns_val = numColumns
        }
        
        var horizontalColumnInset: CGFloat {
            get {
                if let val = horizontalColumnInset_val {
                    return max(0.0, val)
                }
                
                return Self.default.horizontalColumnInset
            }
        }
        
        var verticalColumnInset: CGFloat {
            get {
                if let val = verticalColumnInset_val {
                    return max(0.0, val)
                }
                
                return Self.default.verticalColumnInset
            }
        }
        
        var horizontalColumnSpacing: CGFloat {
            get {
                if let val = horizontalColumnSpacing_val {
                    return max(0.0, val)
                }
                
                return Self.default.horizontalColumnSpacing
            }
        }
        
        
        var verticalItemSpacing: CGFloat {
            get {
                if let val = verticalItemSpacing_val {
                    return max(0.0, val)
                }
                
                return Self.default.verticalItemSpacing
            }
        }
        
        var numColumns: Int {
            get {
                if let val = numColumns_val {
                    return max(1, val)
                }
                
                return Self.default.numColumns
            }
        }
        
        static func ==(lhs: Self, rhs: Self) -> Bool {
            return lhs.horizontalColumnInset   == rhs.horizontalColumnInset   &&
                   lhs.verticalColumnInset     == rhs.verticalColumnInset     &&
                   lhs.horizontalColumnSpacing == rhs.horizontalColumnSpacing &&
                   lhs.verticalItemSpacing     == rhs.verticalItemSpacing     &&
                   lhs.numColumns              == rhs.numColumns
        }
    }
}
