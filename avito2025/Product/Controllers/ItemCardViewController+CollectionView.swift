//
//  ItemCardViewController+CollectionView.swift
//  avito2025
//
//  Created by Richard Dzubko on 15.02.2025.
//

import UIKit

extension ItemCardViewController: UICollectionViewDataSource {
    
    fileprivate var photoCollectionViewLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 4
        layout.scrollDirection = .horizontal
        
        let itemWidth = self.photoCarousel.frame.width
        let itemHeight = itemWidth * ImageCarouselCell.heightToWidthRatio
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        return layout
    }
    
    func setupCollectionView() {
        photoCarousel.register(ImageCarouselCell.self, forCellWithReuseIdentifier: ImageCarouselCell.reuseIdentifier)
        
        photoCarousel.dataSource = self
        photoCarousel.delegate = self
        
        photoCarousel.collectionViewLayout = photoCollectionViewLayout
    }
    
    func setupPageControl(imagesCount: Int) {
        pageControl.numberOfPages = imagesCount
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: photoCarousel.bottomAnchor, constant: 10),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch status {
        case .loading:
            return 1
        case .loaded(let model), .ready(let model), .performingAction(_, model: let model):
            return model.images.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCarouselCell    .reuseIdentifier, for: indexPath) as! ImageCarouselCell
        
        switch status {
        case .loaded(let model), .ready(let model), .performingAction(_, model: let model):
            cell.configure(with: model.images[indexPath.item])
        default:
            break
        }
        
        return cell
    }
}

extension ItemCardViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = collectionView.frame.width
//        let height = width * ImageCarouselCell.heightToWidthRatio
//        return CGSize(width: width, height: height)
//    }
    
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
//        pageControl.currentPage = Int(pageIndex)
//    }
}
