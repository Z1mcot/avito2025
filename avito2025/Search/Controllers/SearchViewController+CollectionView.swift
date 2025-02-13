//
//  ViewController+Collection.swift
//  avito2025
//
//  Created by Richard Dzubko on 13.02.2025.
//

import UIKit

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductMiniViewCell.nibIdentifier, for: indexPath) as! ProductMiniViewCell
        
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegate {
    
}


extension SearchViewController {
    func setupProductCollection() {
        productsCollection.register(ProductMiniViewCell.nib, forCellWithReuseIdentifier: ProductMiniViewCell.nibIdentifier)
        
        productsCollection.dataSource = self
        productsCollection.collectionViewLayout = productCollectionViewLayout
    }
    
    fileprivate var productCollectionViewLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 4
        layout.scrollDirection = .vertical
        
        let itemWidth = self.productsCollection.frame.width / 2 - 4
        let itemHeight = itemWidth * ProductMiniViewCell.heigthToWidthRatio
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        return layout
    }
}
