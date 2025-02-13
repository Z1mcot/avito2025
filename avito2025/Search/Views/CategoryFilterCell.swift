//
//  CategoryFilterCell.swift
//  avito2025
//
//  Created by Richard Dzubko on 13.02.2025.
//

import UIKit

class CategoryFilterCell: UICollectionViewCell {

    @IBOutlet weak var labelBackground: UIView!
    @IBOutlet weak var label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelBackground.layer.cornerRadius = 16
    }
    
    func configure(with text: String) {
        label.text = text
    }
    
    func selectCell() {
        labelBackground.backgroundColor = UIColor.tintColor
    }
    
    func deselectCell() {
        labelBackground.backgroundColor = UIColor.background
    }
}

extension CategoryFilterCell {
    static let nibName = "CategoryFilterCell"
    static let nibIdentifier = "CategoryFilterCellReusable"
    
    static var nib: UINib {
        UINib(nibName: nibName, bundle: nil)
    }
}
