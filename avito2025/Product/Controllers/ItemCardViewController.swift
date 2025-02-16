//
//  ItemCardViewController.swift
//  avito2025
//
//  Created by Richard Dzubko on 15.02.2025.
//

import UIKit

class ItemCardViewController: UIViewController {
    enum Status {
        case initial
        case loading(id: Int)
        case loaded(Product)
        case performingAction(ProductItemAction, model: Product)
        case ready(Product)
        case error(Error)
    }
    
    // MARK: model and dependencies
    var status: Status = .initial {
        didSet {
            switch status {
                
            case .initial:
                return
            case .loading(id: let id):
                fetchItem(oldStatus: oldValue, id: id)
            case .loaded(let model):
                setModel(model)
            case .performingAction(let action, model: let model):
                handleAction(action, model: model)
            case .ready(let model):
                unlockButtons(model)
            case .error(_):
                handleError()
            }
        }
    }
    
    var cartRepository: CartRepository!
    var productRepository: ProductRepository!
    var productId: Int!
    
    // MARK: outlets
    @IBOutlet weak var photoCarousel: UICollectionView!
    let pageControl = UIPageControl()
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    
    @IBOutlet weak var categoryBackground: UIView!
    
    @IBOutlet weak var decrementItemQuantityButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var incrementItemQuantityButton: UIButton!
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        categoryBackground.layer.cornerRadius = 8
        
        categoryImage.layer.cornerRadius = 8
        
        buttonsView.layer.cornerRadius = 20
        
        status = .loading(id: productId)
    }
    
    @IBAction func decrementQuantity(_ sender: Any) {
        guard case .ready(let model) = status else {
            return
        }
        
        status = .performingAction(.decrement, model: model)
    }
    
    @IBAction func buy(_ sender: Any) {
        guard case .ready(let model) = status else {
            return
        }
        
        cartRepository.addObserver(self, id: self.hash)
        
        status = .performingAction(.increment, model: model)
    }
    
    @IBAction func incrementQuantity(_ sender: Any) {
        guard case .ready(let model) = status else {
            return
        }
        
        status = .performingAction(.increment, model: model)
    }
    
    private func fetchItem(oldStatus: Status, id: Int) {
        if case .initial = oldStatus {
            errorView.alpha = 1
        } else {
            errorView.alpha = 0.8
        }
        
        errorView.isHidden = false
        messageView.isHidden = true
        loader.isHidden = false
        
        if !loader.isAnimating {
            loader.startAnimating()
        }
        
        Task {
            do {
                let product = try await productRepository.getProductById(id)
                
                status = .loaded(product)
            } catch {
                status = .error(error)
            }
        }
    }
    
    private func setModel(_ model: Product) {
        photoCarousel.reloadData()
        
        errorView.isHidden = true
        loader.isHidden = true
        
        priceLabel.text = "$ \(model.price)"
        titleLabel.text = model.title
        descriptionText.text = model.description
        
        categoryName.text = model.category.name
        
        if model.quantity > 0 {
            cartRepository.addObserver(self, id: self.hash)
        }
        
        if let imageUrl = model.category.image {
            loadCategoryImage(imageUrl)
        }
        
        status = .ready(model)
    }
    
    private func handleAction(_ action: ProductItemAction, model: Product) {
        blockButtons()
        do {
            switch action {
            case .increment:
                try incrementCartItemQuantity(model)
            case .decrement:
                try decrementCartItemQuantity(model)
            }
        } catch DBError.itemNotFound, DBError.creationFailed {
            var newModel = model
            newModel.set(newQuantity: 0)
            status = .ready(model)
            return
        } catch DBError.updateFailed, DBError.deleteFailed {
            status = .ready(model)
            return
        } catch {
            assert(false)
        }
    }
    
    private func handleError() {
        errorView.isHidden = false
        messageView.isHidden = false
    }
    
    private func blockButtons() {
        decrementItemQuantityButton.isEnabled = false
        buyButton.isEnabled = false
        incrementItemQuantityButton.isEnabled = false
    }
    
    private func unlockButtons(_ model: Product) {
        buyButton.setTitle("\(model.quantity)", for: .disabled)
        model.quantity == 0 ? enableBuyButton()
                            : disableBuyButton()
    }
    
    private func incrementCartItemQuantity(_ model: Product) throws {
        var newModel = model
        newModel.incrementQuantity()
        
        try cartRepository.addToCart(product: newModel)
    }
    
    private func decrementCartItemQuantity(_ model: Product) throws {
        var newModel = model
        newModel.decrementQuantity()
        
        try cartRepository.removeFromCart(product: newModel)
    }
    
    private func disableBuyButton() {
        decrementItemQuantityButton.isEnabled = true
        incrementItemQuantityButton.isEnabled = true
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.buyButton.isEnabled = false
            
            self?.decrementItemQuantityButton.isHidden = false
            self?.incrementItemQuantityButton.isHidden = false
        }
    }
    
    private func enableBuyButton() {
        decrementItemQuantityButton.isEnabled = false
        incrementItemQuantityButton.isEnabled = false
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.buyButton.isEnabled = true
            
            self?.buyButton.setTitle("Buy", for: .normal)
            
            self?.decrementItemQuantityButton.isHidden = true
            self?.incrementItemQuantityButton.isHidden = true
        }
    }
    
    private func loadCategoryImage(_ url: String) {
        Task {
            let image = try? await ImageService.shared.getImage(from: url)
            
            if image == nil {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.categoryImage.image = image
            }
        }
    }
}

// MARK: - Cart Observer
extension ItemCardViewController: CartObserver {
    func onItemAdded(_ newItem: Product) {
        switch status {
        case .ready(let model), .performingAction(_, model: let model), .loaded(let model):
            if newItem.id != model.id {
                return
            }
            status = .ready(newItem)
        default:
            return
        }
    }
    
    func onItemRemoved(_ removedItem: Product) {
        switch status {
        case .ready(let model), .performingAction(_, model: let model), .loaded(let model):
            if removedItem.id != model.id {
                return
            }
            
            if removedItem.quantity == 0 {
                cartRepository.removeObserver(id: self.hash)
            }
            
            status = .ready(removedItem)
        default:
            return
        }
    }
    
    func onCartCleared() {
        enableBuyButton()
    }
}

// MARK: - Segue related
extension ItemCardViewController {
    func injectDependecies(productId: Int, cartRepository: CartRepository, productRepository: ProductRepository) {
        self.cartRepository = cartRepository
        self.productRepository = productRepository
        self.productId = productId
    }
    
    static let segueFromSearchId = "SearchToItemCardSegue"
    static let segueFromCartId = "CartToItemCardSegue"
}
