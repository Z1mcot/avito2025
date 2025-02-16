//
//  FilterViewController.swift
//  avito2025
//
//  Created by Richard Dzubko on 13.02.2025.
//

import UIKit

protocol ProductFilterSearchDelegate {
    func onFiltersChanged(filters: ProductFilters)
}

class FilterViewController: UIViewController {
    internal var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var filters: ProductFilters!
    var delegate: ProductFilterSearchDelegate?
    
    var categories: [Category] = []
    
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    @IBOutlet weak var priceModeControl: UISegmentedControl!
    @IBOutlet weak var minPriceField: UITextField!
    @IBOutlet weak var maxPriceField: UITextField!
    
    var tapRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollection()
        
        if let maxPrice = filters.maxPrice {
            maxPriceField.text = "\(maxPrice)"
        }
        
        if let price = filters.targetPrice {
            priceModeControl.selectedSegmentIndex = 1
            minPriceField.text = "\(price)"
        } else if let price = filters.minPrice {
            minPriceField.text = "\(price)"
        }
        
        minPriceField.addDoneCancelToolbar(
            onDone: (target: self, action: #selector(minTextFieldShouldReturn))
        )
        maxPriceField.addDoneCancelToolbar()
        
        tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard)
        )
    }
    
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewHeight()
    }
    
    @IBAction func onFiltersApplied(_ sender: UIButton) {
        if let minPriceText = minPriceField.text {
            let newValue = Int(minPriceText)
            if priceModeControl.selectedSegmentIndex == 1 {
                filters.targetPrice = newValue
            } else {
                filters.minPrice = newValue
            }
        }
        
        if let maxPriceText = maxPriceField.text,
            priceModeControl.selectedSegmentIndex == 0 {
            filters.maxPrice = Int(maxPriceText)
        }
        
        
        delegate?.onFiltersChanged(filters: filters)
        dismiss(animated: true)
    }
    
    @IBAction func onPriceInputModeChanged(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.maxPriceField.isHidden.toggle()
        }
        
        if sender.selectedSegmentIndex == 1 {
            minPriceField.placeholder = "Enter your price"
        } else {
            minPriceField.placeholder = "min"
        }
    }
}

extension FilterViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.removeGestureRecognizer(tapRecognizer)
    }
}

extension FilterViewController {
    @objc func minTextFieldShouldReturn() {
        if maxPriceField.isHidden {
            minPriceField.resignFirstResponder()
        } else {
            maxPriceField.becomeFirstResponder()
        }
    }
}

// MARK: - Segue Related
extension FilterViewController {
    func injectDependecies(_ categories: [Category], filters: ProductFilters, delegate: ProductFilterSearchDelegate? = nil) {
        self.categories = categories
        self.filters = filters
        self.delegate = delegate
    }
    
    static var segueId: String {
        return "SearchToFilterSegue"
    }
}
