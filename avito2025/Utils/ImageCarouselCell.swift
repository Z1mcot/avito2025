//
//  ImageCarouselCell.swift
//  avito2025
//
//  Created by Richard Dzubko on 15.02.2025.
//

import UIKit

class ImageCarouselCell: UICollectionViewCell {
    private var imageUrl: String!
    private let imageView = UIImageView()
    private let skeletonLoaderView = SkeletonLoaderView()
    
    static let reuseIdentifier = "ImageCarouselCell"
    
    static let heightToWidthRatio: CGFloat = 320 / 393
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        skeletonLoaderView.contentMode = .scaleAspectFill
        skeletonLoaderView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(skeletonLoaderView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        skeletonLoaderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
                skeletonLoaderView.topAnchor.constraint(equalTo: contentView.topAnchor),
                skeletonLoaderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                skeletonLoaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                skeletonLoaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func loadImage() {
        Task {
            let image = try? await ImageService.shared.getImage(from: imageUrl)
            
            let safeImage = image ?? UIImage(named: "Placeholder")
            
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = safeImage
                self?.skeletonLoaderView.isHidden = true
            }
        }
    }
    
    func configure(with url: String) {
        imageUrl = url
        
        loadImage()
    }
}
