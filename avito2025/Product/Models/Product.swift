//
//  Product.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

struct Product: Decodable {
    let id: Int
    let title: String
    let price: Int
    let description: String
    let category: Category
    let images: [String]
}
