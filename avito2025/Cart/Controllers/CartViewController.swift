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
        case navigating(Int)
    }
    
    // MARK: model
    var status: Status = .empty {
        didSet {
            switch status {
                
            case .empty:
                showEmptyMessage()
            case .loading:
                showLoader(previousStatus: oldValue)
                fetchCart()
            case .loaded(let items):
                handleNewItems(items)
            case .clearing:
                clearCart()
            case .ready(_):
                updateView()
            case .navigating(_):
                showLoader()
            }
        }
    }
    var cartRepository: CartRepository!
    var productRepository: ProductRepository!
    
    // MARK: outlets
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
        
        setupTableView()
        
        status = .loading
    }
    
    // MARK: actions
    @IBAction func shareCart(_ sender: Any) {
        var messageText: [String] = []
        
        switch status {
        case .loaded(let model), .ready(let model):
            messageText = [ model.map { $0.toText() }.joined(separator: "\n\n") ]
        default:
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: messageText, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        present(activityViewController, animated: true)
    }
    
    @IBAction func onClearCart(_ sender: Any) {
        status = .clearing
    }
    
    
    deinit {
        cartRepository.removeObserver(id: self.hash)
    }
    
    // MARK: - UI Updates
    func showEmptyMessage() {
        clearCartButton.isHidden = true
        shareButton.isHidden = true
        
        loader.isHidden = true
        loader.stopAnimating()
        
        loaderView.alpha = 1
        loaderView.isHidden = false
        messageLabel.text = "Your cart is empty. Try searching for something!"
        messageLabel.isHidden = false
    }
    
    func showLoader(previousStatus: Status? = nil) {
        blockButtons()
        
        loader.isHidden = false
        loader.startAnimating()
        
        loaderView.isHidden = false
        messageLabel.isHidden = true
        
        if case .empty = previousStatus {
            loaderView.alpha = 1
        }
        
        loaderView.alpha = 0.5
    }
    
    func fetchCart() {
        let cartItems = cartRepository.getCart()
        status = cartItems.isEmpty ? .empty
                                   : .loaded(cartItems)
    }
    
    func handleNewItems(_ items: [CartItem]) {
        clearCartButton.isHidden = false
        shareButton.isHidden = false
        
        unblockButtons()
        
        cartItemsTable.reloadData()
        
        loaderView.isHidden = true
        loader.stopAnimating()
    }
    
    func clearCart() {
        blockButtons()
        
        loaderView.isHidden = false
        loaderView.alpha = 1
        loader.isHidden = false
        loader.startAnimating()
        messageLabel.text = "Clearing your cart. Please wait..."
        messageLabel.isHidden = false
        
        do {
            try cartRepository.clearCart()
            status = .empty
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

// MARK: - nib related
extension CartViewController {
    func injectDependencies(cartRepository: CartRepository, productRepository: ProductRepository) {
        self.cartRepository = cartRepository
        self.productRepository = productRepository
        self.cartRepository.addObserver(self, id: self.hash)
    }
    
    static let segueId = "SearchToCartSegue"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier{
        case ItemCardViewController.segueFromCartId:
            prepareItemCardSegue(segue)
        default:
            break
        }
        status = .loading
    }
    
    func prepareItemCardSegue(_ segue: UIStoryboardSegue) {
        let itemCardVC = segue.destination as! ItemCardViewController
        
        switch status {
        case .navigating(let productId):
            itemCardVC.injectDependecies(productId: productId, cartRepository: cartRepository, productRepository: productRepository)
        default:
            break
        }
    }
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
        status = newCart.isEmpty ? .empty : .ready(newCart)
    }
    
    func onCartCleared() {
        status = .empty
    }
}
