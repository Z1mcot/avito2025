//
//  CartItem+Text.swift
//  avito2025
//
//  Created by Richard Dzubko on 16.02.2025.
//

extension CartItem {
    func toText() -> String {
        "\(title ?? "Item id: \(itemId)")\n$\(price)\nqty: \(quantity)"
    }
}
