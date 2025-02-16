//
//  CartViewController.swift
//  avito2025
//
//  Created by Richard Dzubko on 15.02.2025.
//

import UIKit

class CartViewController: UIViewController {
    
    enum Status {
        case empty
        case loading
        case loaded([CartItem])
        case clearing
        case ready([CartItem])
    }
    
    // MARK: model
    var status: Status = .empty {
        didSet {
            switch status {
                
            case .empty:
                showEmptyMessage()
            case .loading:
                showLoader(previousStatus: oldValue)
            case .loaded(let items):
                handleNewItems(items)
            case .clearing:
                clearCart()
            case .ready(_):
                updateView()
            }
        }
    }
    var cartRepository: CartRepository!
    
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    
    @IBOutlet weak var clearCartButton: UIButton!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var cartItemsTable: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearCartButton.isHidden = true
        shareButton.isHidden = true
        
        cartItemsTable.register(CartItemCell.nib, forCellReuseIdentifier: CartItemCell.nibIdentifier)
        
        cartItemsTable.estimatedRowHeight = 220
        
        cartItemsTable.dataSource = self
        cartItemsTable.delegate = self
        
        status = .loading
    }
    
    deinit {
        cartRepository.removeObserver(id: self.hash)
    }
    
    func showEmptyMessage() {
        clearCartButton.isHidden = true
        shareButton.isHidden = true
        
        loader.isHidden = true
        loader.stopAnimating()
        
        loaderView.alpha = 1
        loaderView.isHidden = false
        messageLabel.text = "Your cart is empty. Try searching for something!"
    }
    
    func showLoader(previousStatus: Status) {
        blockButtons()
        
        loader.isHidden = false
        loader.startAnimating()
        
        loaderView.isHidden = false
        
        if case .empty = previousStatus {
            loaderView.alpha = 1
        }
        
        loaderView.alpha = 0.5
        
        let cartItems = cartRepository.getCart()
        status = cartItems.isEmpty ? .empty
                                   : .loaded(cartItems)
    }
    
    func handleNewItems(_ items: [CartItem]) {
        clearCartButton.isHidden = false
        clearCartButton.isEnabled = true
        shareButton.isHidden = false
        cartItemsTable.reloadData()
        
        loaderView.isHidden = true
        loader.stopAnimating()
    }
    
    func clearCart() {
        blockButtons()
        
        loader.isHidden = false
        loader.startAnimating()
        loaderView.isHidden = false
        loaderView.alpha = 1
        messageLabel.text = "Clearing your cart. Please wait..."
        
        do {
            try cartRepository.clearCart()
            status = .clearing
        } catch {
            status = .loading
        }
    }
    
    func updateView() {
        unblockButtons()
        loaderView.isHidden = true
        loader.stopAnimating()
        cartItemsTable.reloadData()
    }
    
    func blockButtons() {
        clearCartButton.isEnabled = false
        shareButton.isEnabled = false
    }
    
    func unblockButtons() {
        clearCartButton.isEnabled = true
        shareButton.isEnabled = true
    }
}

extension CartViewController {
    func injectDependencies(repository: CartRepository) {
        cartRepository = repository
        cartRepository.addObserver(self, id: self.hash)
    }
    
    static let segueId = "SearchToCartSegue"
}

// MARK: - Cart Observer
extension CartViewController: CartObserver {
    func onItemAdded(_ newItem: Product) {
        if newItem.quantity != 1 {
            return
        }
        
        let newCart = cartRepository.getCart()
        status = .ready(newCart)
    }
    
    func onItemRemoved(_ removedItem: Product) {
        if removedItem.quantity != 0 {
            return
        }
        
        let newCart = cartRepository.getCart()
        status = .ready(newCart)
    }
    
    func onCartCleared() {
        status = .empty
    }
}
