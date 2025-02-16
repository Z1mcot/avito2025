//
//  FilterViewController+CollectionView.swift
//  avito2025
//
//  Created by Richard Dzubko on 14.02.2025.
//

import UIKit

extension FilterViewController: UICollectionViewDataSource {
    
    func configureCollection() {
        categoriesCollectionView.register(CategoryFilterCell.nib, forCellWithReuseIdentifier: CategoryFilterCell.nibIdentifier)
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        
        categoriesCollectionView.isScrollEnabled = false
        collectionViewHeightConstraint = categoriesCollectionView.heightAnchor.constraint(equalToConstant: 50)
        collectionViewHeightConstraint.isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryFilterCell.nibIdentifier, for: indexPath) as! CategoryFilterCell
        
        cell.configure(with: categories[indexPath.item])
        
        if filters.categoryId == categories[indexPath.item].id {
            cell.selectCell()
        }
        
        return cell
    }
}

extension FilterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryFilterCell
        
        cell.deselectCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryFilterCell
        
        if filters.categoryId == categories[indexPath.item].id {
            cell.isSelected = false
            filters.categoryId = nil
            cell.deselectCell()
            return
        }
        
        filters.categoryId = categories[indexPath.item].id
        
        cell.selectCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = categories[indexPath.item].name
            
        // Calculate text width
        let textWidth = text.size(withAttributes: [.font: UIFont.systemFont(ofSize: 20)]).width
        
        // Add padding (8 on each side for the label + container padding)
        let cellWidth = textWidth + 16
        return CGSize(width: cellWidth, height: 32)
    }
    
    func updateCollectionViewHeight() {
        categoriesCollectionView.layoutIfNeeded()
        let height = categoriesCollectionView.collectionViewLayout.collectionViewContentSize.height
        collectionViewHeightConstraint.constant = height
    }
}
