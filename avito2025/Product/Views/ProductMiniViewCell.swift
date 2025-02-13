//
//  ProductView.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import UIKit

class ProductMiniViewCell: UICollectionViewCell {
    
    private var model: Product!
    private var repository: ProductRepository!
    
    @IBOutlet weak var productBackgroundView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var priceTag: UILabel!
    
    func injectDependencies(model: Product, repository: ProductRepository) {
        if let photoUrlString = model.images.first {
            getImage(photoUrlString)
        }
        
        productName.text = model.title
        priceTag.text = "$\(model.price)"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let cornerRadius: CGFloat = 16
        
        productBackgroundView.layer.cornerRadius = cornerRadius
//        productBackgroundView.layer.borderWidth = 1
//        productBackgroundView.layer.borderColor = UIColor
        
        productImageView.layer.cornerRadius = cornerRadius - 8
    }
    
    private func getImage(_ url: String) {
        Task { [weak self] in
            let image = try? await self?.repository.getProductImage(by: url)
            
            if image == nil {
                return
            }
            
            DispatchQueue.main.async {
                self?.productImageView.image = image
            }
        }
    }
}

extension ProductMiniViewCell {
    static let nibName = "ProductMiniViewCell"
    static let nibIdentifier = "ProductMiniViewCellReusable"
    
    static let heigthToWidthRatio: CGFloat = 387 / 304
    
    static var nib: UINib {
        UINib(nibName: nibName, bundle: nil)
    }
}
