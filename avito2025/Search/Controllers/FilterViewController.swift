//
//  FilterViewController.swift
//  avito2025
//
//  Created by Richard Dzubko on 13.02.2025.
//

import UIKit

class FilterViewController: UIViewController {
    internal var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var filters: ProductFilters!
    
//    let mockCategories = []
    
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollection()
        
//        categoriesCollectionView.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewHeight()
    }
    
    func setFilters(_ filters: ProductFilters) {
        self.filters = filters
    }
}

extension FilterViewController {
    static var storyboardId = "FilterViewControllerId"
    
    static var segueId: String {
        return "FilterViewControllerSegueId"
    }
}
