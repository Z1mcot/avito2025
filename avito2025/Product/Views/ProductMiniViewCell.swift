//
//  ProductView.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import UIKit

enum ProductItemAction {
    case increment
    case decrement
}

enum ProductMiniViewCellStatus: Equatable {
    case loading
    case loaded(model: Product)
    case performingAction(ProductItemAction, model: Product)
    case ready(model: Product)
}

class ProductMiniViewCell: UICollectionViewCell {
    
    // MARK: properties
    private var status: ProductMiniViewCellStatus = .loading {
        didSet {
            if oldValue == status {
                return
            }
            
            switch status {
            case .loading:
                showSkeletonLoader()
            case .loaded(let newModel):
                setModel(newModel: newModel)
            case .performingAction(let action, let model):
                handleAction(action, model: model)
            case .ready(let model):
                unlockButtons(model: model)
            }
        }
    }
    
    private var repository: CartRepository!
    private var imageService: ImageService!
    private var currentModel: Product!
    
    // MARK: outlets and views
    @IBOutlet weak var skeletonView: SkeletonLoaderView!
    
    @IBOutlet weak var productBackgroundView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var priceTag: UILabel!
    
    
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var decrementButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var incrementButton: UIButton!
    
    func injectDependencies(repository: CartRepository, imageService: ImageService) {
        self.repository = repository
        self.imageService = imageService
        status = .loading
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        showSkeletonLoader()
        
        let cornerRadius: CGFloat = 16
        
        buttonStackView.layer.cornerRadius = 8
        buttonStackView.backgroundColor = .tintColor
        buyButton.setTitle("Buy", for: .normal)
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.setTitleColor(.black, for: .disabled)
        
        productBackgroundView.layer.cornerRadius = cornerRadius
        
        productImageView.layer.cornerRadius = cornerRadius - 8
    }
    
    deinit {
//        repository.removeObserver(id: self.hash)
    }
    
    @IBAction func onBuyItem(_ sender: UIButton) {
        guard case .ready(let model) = status else {
            return
        }
        
        repository.addObserver(self, id: self.hash)
        
        status = .performingAction(.increment, model: model)
    }
    
    @IBAction func onDecrementItemCount(_ sender: UIButton) {
        guard case .ready(let model) = status else {
            return
        }
        
        status = .performingAction(.decrement, model: model)
    }
    
    @IBAction func onIncrementItemCount(_ sender: UIButton) {
        guard case .ready(let model) = status else {
            return
        }
        
        status = .performingAction(.increment, model: model)
    }
    
    private func getImage(_ url: String) {
        Task { [weak self] in
            var image = try? await self?.imageService.getImage(from: url)
            
            if image == nil {
                image = UIImage(named: "Placeholder")
            }
            
            DispatchQueue.main.async {
                self?.productImageView.image = image
            }
        }
    }
}

// MARK: - Status Change Handlers
extension ProductMiniViewCell {
    fileprivate func showSkeletonLoader() {
        skeletonView.isHidden = false
        skeletonView.translatesAutoresizingMaskIntoConstraints = false
        skeletonView.layer.cornerRadius = 8
        skeletonView.clipsToBounds = true
    }
    
    
    func setModel(newModel model: Product) {
        defer {
            productName.text = model.title
            priceTag.text = "$\(model.price)"
            skeletonView.isHidden = true
        }
        
        if let photoUrlString = model.images.first {
            getImage(photoUrlString)
        }
        
        if model.quantity > 0 {
            repository.addObserver(self, id: self.hash)
            onItemAdded(model)
        }
        
        status = .ready(model: model)
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
            status = .ready(model: model)
            return
        } catch DBError.updateFailed, DBError.deleteFailed {
            status = .ready(model: model)
            return
        } catch {
            assert(false)
        }
    }
    
    private func unlockButtons(model: Product) {
        buyButton.setTitle("\(model.quantity)", for: .disabled)
        model.quantity == 0 ? enableBuyButton()
                            : disableBuyButton()
    }
    
    private func incrementCartItemQuantity(_ model: Product) throws {
        var newModel = model
        newModel.incrementQuantity()
        
        try repository.addToCart(product: newModel)
    }
    
    private func decrementCartItemQuantity(_ model: Product) throws {
        var newModel = model
        newModel.decrementQuantity()
        
        try repository.removeFromCart(product: newModel)
    }
    
    private func disableBuyButton() {
        decrementButton.isEnabled = true
        incrementButton.isEnabled = true
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.buyButton.isEnabled = false
            self?.buttonStackView.backgroundColor = .element
            
            self?.decrementButton.isHidden = false
            self?.incrementButton.isHidden = false
        }
    }
    
    private func enableBuyButton() {
        decrementButton.isEnabled = false
        incrementButton.isEnabled = false
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.buyButton.isEnabled = true
            self?.buttonStackView.backgroundColor = .tintColor
            
            self?.decrementButton.isHidden = true
            self?.incrementButton.isHidden = true
        }
    }
    
    private func blockButtons() {
        buyButton.isEnabled = false
        decrementButton.isEnabled = false
        incrementButton.isEnabled = false
    }
}

// MARK: - Cart Observer

extension ProductMiniViewCell: CartObserver {
    func onItemAdded(_ newItem: Product) {
        switch status {
        case .ready(let model), .loaded(let model), .performingAction(_, model: let model):
            if newItem.id == model.id {
                status = .ready(model: newItem)
            }
        default:
            return
        }
    }
    
    func onItemRemoved(_ removedItem: Product) {
        switch status {
        case .ready(let model), .loaded(let model), .performingAction(_, model: let model):
            if removedItem.id != model.id {
                return
            }
            
            if removedItem.quantity == 0 {
                repository.removeObserver(id: self.hash)
            }
            
            status = .ready(model: removedItem)
        default:
            return
        }
    }
    
    func onCartCleared() {
        enableBuyButton()
    }
    
    
}

// MARK: - NIB related
extension ProductMiniViewCell {
    static let nibName = "ProductMiniViewCell"
    static let nibIdentifier = "ProductMiniViewCellReusable"
    
    static let heigthToWidthRatio: CGFloat = 387 / 304
    
    static var nib: UINib {
        UINib(nibName: nibName, bundle: nil)
    }
}
