//
//  ViewController+Collection.swift
//  avito2025
//
//  Created by Richard Dzubko on 13.02.2025.
//

import UIKit

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch status {
        case .loading:
            if products.count > 0 {
               return products.count //+ 2
            }
            return 10
        case .loaded(_, _):                
            return products.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductMiniViewCell.nibIdentifier, for: indexPath) as! ProductMiniViewCell
        
        if indexPath.item >= products.count {
            return cell
        }
        
        cell.injectDependencies(repository: cartRepository, imageService: ImageService.shared)
        
        switch status {
        case .empty, .loaded(_, _), .loading(_):
            var model = products[indexPath.item]
            if let quantity = cartLookupTable[Int64(model.id)] {
                model.quantity = quantity
            }
            
            cell.setModel(newModel: model)
        default: break
        }
        
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        switch status {
        case .empty, .loaded(_, _):
            selectedId = products[indexPath.item].id
            performSegue(withIdentifier: ItemCardViewController.segueFromSearchId, sender: self)
        default :
            break
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !canFetchMore {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.height
        
        switch status {
        case .loaded(_, let filters):
            if !savedThisQuery && !filters.isEmpty {
                try? searchRepository.saveQuery(filters)
                savedThisQuery = true
            }
            
            if offsetY > contentHeight * 0.8 - scrollViewHeight {
                status = .loading(filters)
            }
        default:
            return
        }
    }
}


extension SearchViewController {
    func setupProductCollection() {
        productsCollection.register(ProductMiniViewCell.nib, forCellWithReuseIdentifier: ProductMiniViewCell.nibIdentifier)
        
        productsCollection.dataSource = self
        productsCollection.delegate = self
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
