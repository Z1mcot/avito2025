//
//  Product.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

struct Product: Decodable, Equatable {
    /// Should be used when you have UICollectionView insert/delete logic and you don't want to update it
    static let nonexistingProduct = Product(id: -1, title: "", price: 0, description: "", category: Category(id: -1, name: ""), images: [], quantity: -1, position: -1)
    
    let id: Int
    let title: String
    let price: Int
    let description: String
    let category: Category
    let images: [String]
    
    var quantity: Int = 0
    
    var position: Int?
    
    init(id: Int, title: String, price: Int, description: String, category: Category, images: [String]) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.category = category
        self.images = images
    }
    
    init(id: Int, title: String, price: Int, description: String, category: Category, images: [String], quantity: Int, position: Int? = nil) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.category = category
        self.images = images
        self.quantity = quantity
        self.position = position
    }
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case price
        case description
        case category
        case images
    }
    
    static func from(_ item: CartItem) -> Product {
        return Product(
            id: Int(item.itemId),
            title: item.title!,
            price: Int(item.price),
            description: "",
            category: Category(id: 0, name: ""),
            images: [],
            quantity: Int(item.quantity),
            position: Int(item.position)
        )
    }
    
    mutating func set(newQuantity: Int) {
        quantity = newQuantity
    }
    
    mutating func incrementQuantity() {
        quantity += 1
    }
    
    mutating func decrementQuantity() {
        guard quantity > 0 else { return }
        quantity -= 1
    }
}
