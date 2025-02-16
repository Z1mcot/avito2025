//
//  CartRepository.swift
//  avito2025
//
//  Created by Richard Dzubko on 15.02.2025.
//

import Foundation

protocol CartObserver {
    func onItemAdded(_ newItem: Product)
    func onItemRemoved(_ removedItem: Product)
    func onCartCleared()
}

class CartRepository {
    private let dbService: DBService
    
    private var observers: [Int: CartObserver] = [:]
    
    init(dbService: DBService) {
        self.dbService = dbService
    }
    
    func addObserver(_ observer: CartObserver, id: Int) {
        observers[id] = observer
    }
    
    func removeObserver(id: Int) {
        observers[id] = nil
    }
    
    /// Should be used only after getting message inside `CartObserver` `onItemAdded`
    func getItem(by model: Product) -> CartItem {
        let item = try? dbService.get(one: model)
        
        assert(item != nil, "No item with such model. Model: \(model)")
        
        return item as! CartItem
    }
    
    func getCart() -> [CartItem] {
        let sort = NSSortDescriptor(key: #keyPath(CartItem.position), ascending: true)
        
        let items = try? dbService.get(all: CartItem.self, sort: sort)
        
        return items ?? []
    }
    
    func addToCart(product: Product) throws {
        if product.quantity == 1 {
            try dbService.add(product)
        } else {
            try dbService.update(product)
        }
        
        for observer in observers.values {
            observer.onItemAdded(product)
        }
    }
    
    func addToCart(item: CartItem) throws {
        try dbService.update(item)
        
        let productModel = Product.from(item)
        for observer in observers.values {
            observer.onItemAdded(productModel)
        }
    }
    
    func removeFromCart(product: Product) throws {
        var mutableProduct = product
        if mutableProduct.quantity == 0 {
            let entity = try dbService.get(one: mutableProduct) as! CartItem
            mutableProduct.position = Int(entity.position)
            try dbService.delete(mutableProduct)
        } else {
            try dbService.update(mutableProduct)
        }
        
        for observer in observers.values {
            observer.onItemRemoved(mutableProduct)
        }
    }
    
    func removeFromCart(item: CartItem) throws {
        let productModel = Product.from(item)
        
        item.quantity == 0 ? try dbService.delete(item)
                           : try dbService.update(item)
        
        for observer in observers.values {
            observer.onItemRemoved(productModel)
        }
    }
    
    func movePosition(item: CartItem, to destination: Int) throws {
        try dbService.update(item, newPosition: destination)
    }
    
    func clearCart() throws {
        try dbService.delete(all: CartItem.self)
        
        for observer in observers.values {
            observer.onCartCleared()
        }
    }
}
