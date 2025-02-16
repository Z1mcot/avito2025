//
//  CartItemCell.swift
//  avito2025
//
//  Created by Richard Dzubko on 15.02.2025.
//

import UIKit

class CartItemCell: UITableViewCell {
    
    enum Status {
        case initial
        case loaded
        case ready
        case performingAction(ProductItemAction)
    }
    
    private var model: CartItem!
    private(set) var status: Status = .initial {
        didSet {
            switch status {
                
            case .initial:
                skeletonLoader.isHidden = false
            case .loaded:
                setModel()
            case .ready:
                updateView()
            case .performingAction(let action):
                handleAction(action)
            }
        }
    }
    
    private var repository: CartRepository!
    
    @IBOutlet weak var cartItemBackground: UIView!
    
    @IBOutlet weak var skeletonLoader: SkeletonLoaderView!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var deleteItemButton: UIButton!
    
    @IBOutlet weak var quantityButtonsStackView: UIStackView!
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var increaseButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        skeletonLoader.isHidden = false
        cartItemBackground.layer.cornerRadius = 20
        skeletonLoader.layer.cornerRadius = 8
        itemImage.layer.cornerRadius = 8
        
        buyButton.setTitleColor(.black, for: .disabled)
        
        quantityButtonsStackView.layer.cornerRadius = 8
    }
    
    @IBAction func deleteItemFromCart(_ sender: Any) {
        guard case .ready = status else {
            return
        }
        
        model.quantity = 1
        
        status = .performingAction(.decrement)
    }
    
    @IBAction func decreaseQuantity(_ sender: Any) {
        guard case .ready = status else {
            return
        }
        
        status = .performingAction(.decrement)
    }
    
    @IBAction func increaseQuantity(_ sender: Any) {
        guard case .ready = status else {
            return
        }
        
        status = .performingAction(.increment)
    }
    
    private func setModel() {
        titleLabel.text = model.title
        priceLabel.text = "$\(model.price)"
        
        repository.addObserver(self, id: self.hash)
        
        if let imageUrl = model.imageUrl {
            getImage(imageUrl)
        } else {
            skeletonLoader.isHidden = true
        }
        
        status = .ready
    }
    
    private func handleAction(_ action: ProductItemAction) {
        blockButtons()
        do {
            switch action {
            case .increment:
                try incrementCartItemQuantity()
            case .decrement:
                try decrementCartItemQuantity()
            }
        } catch DBError.updateFailed, DBError.deleteFailed {
            status = .ready
            return
        } catch {
            assert(false)
        }
    }
    
    private func incrementCartItemQuantity() throws {
        let newModel = model!
        newModel.quantity += 1
        
        try repository.addToCart(item: newModel)
    }
    
    private func decrementCartItemQuantity() throws {
        let newModel = model!
        newModel.quantity -= 1
        
        try repository.removeFromCart(item: newModel)
    }
    
    private func updateView() {
        self.buyButton.setTitle("\(model.quantity)", for: .disabled)
        unblockButtons()
    }
    
    private func unblockButtons() {
        deleteItemButton.isEnabled = true
        decreaseButton.isEnabled = true
        increaseButton.isEnabled = true
    }
    
    private func blockButtons() {
        deleteItemButton.isEnabled = false
        decreaseButton.isEnabled = false
        increaseButton.isEnabled = false
    }
    
    private func getImage(_ url: URL) {
        Task { [weak self] in
            var image = try? await ImageService.shared.getImage(from: url)
            
            if image == nil {
                image = UIImage(named: "Placeholder")
            }
            
            DispatchQueue.main.async {
                self?.skeletonLoader.isHidden = true
                self?.itemImage.image = image
            }
        }
    }
}

// MARK: - Cart Observer
extension CartItemCell: CartObserver {
    func onItemAdded(_ newItem: Product) {
        guard Int(model.itemId) == newItem.id else {
            return
        }
        
        status = .ready
    }
    
    func onItemRemoved(_ removedItem: Product) {
        guard Int(model.itemId) == removedItem.id else {
            return
        }
        
        if removedItem.quantity == 0 {
            repository.removeObserver(id: self.hash)
        } else {
            status = .ready
        }
    }
    
    func onCartCleared() {
        repository.removeObserver(id: self.hash)
    }
}

// MARK: - nib information
extension CartItemCell {
    static let nibName = "CartItemCell"
    static let nibIdentifier = "CartItemCellReusable"
    
    static var nib: UINib {
        UINib(nibName: nibName, bundle: nil)
    }
    
    func injectDependencies(item: CartItem, repository: CartRepository) {
        self.repository = repository
        self.model = item
        status = .loaded
    }
}
