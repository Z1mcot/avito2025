//
//  Category.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//


struct Category: Decodable, Equatable {
    let id: Int
    let name: String
    let image: String?
    
    init(id: Int, name: String, image: String? = nil) {
        self.id = id
        self.name = name
        self.image = image
    }
}
