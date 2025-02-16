//
//  SearchItem.swift
//  avito2025
//
//  Created by Richard Dzubko on 15.02.2025.
//

import UIKit

class SearchItem: UITableViewCell {
    @IBOutlet weak var searchTitleLabel: UILabel!
    @IBOutlet weak var tagsCollection: UICollectionView!
    
    var filters: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagsCollection.register(CategoryFilterCell.nib, forCellWithReuseIdentifier: CategoryFilterCell.nibIdentifier)
        
        tagsCollection.delegate = self
        tagsCollection.dataSource = self
        
    }
}

extension SearchItem: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryFilterCell.nibIdentifier, for: indexPath) as! CategoryFilterCell
        
        cell.configure(
            with: Category(id: 0, name: filters[indexPath.item])
        )
        cell.label.font = UIFont.systemFont(ofSize: 10)
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = filters[indexPath.item]
            
        // Calculate text width
        let textWidth = text.size(withAttributes: [.font: UIFont.systemFont(ofSize: 10)]).width
        
        let cellWidth = textWidth + 8
        return CGSize(width: cellWidth, height: collectionView.frame.height / 2 - 10)
    }
}


// MARK: - nib related
extension SearchItem {
    static let nibName: String = "SearchItem"
    static let reuseIdentifier: String = "SearchItemReusable"
    
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: .main)
    }
    
    func injectDependencies(_ query: LastSearchQuery, categoriesLookupTable: [Int: String]) {
        searchTitleLabel.text = query.searchQuery ?? ""
        filters = []
        
        if query.targetPrice != .zero {
            filters.append("$\(query.targetPrice)")
        } else {
            var priceRange: String = ""
            if query.minPrice != .zero {
                priceRange += "from $\(query.minPrice) "
            }
            if query.maxPrice != .zero {
                priceRange += "up to $\(query.maxPrice)"
            }
            
            if !priceRange.isEmpty {
                filters.append(priceRange)
            }
        }
        
        if let category = categoriesLookupTable[Int(query.categoryId)],
           query.categoryId != .zero{
            filters.append("Category: \(category)")
        }
        
        tagsCollection.reloadData()
    }
}
