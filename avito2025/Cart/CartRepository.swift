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
        product.quantity == 0 ? try dbService.delete(product)
                              : try dbService.update(product)
        
        for observer in observers.values {
            observer.onItemRemoved(product)
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
    
    func clearCart() throws {
        try dbService.delete(all: CartItem.self)
        
        for observer in observers.values {
            observer.onCartCleared()
        }
    }
}
