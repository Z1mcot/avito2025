//
//  CartItem+CoreDataProperties.swift
//  avito2025
//
//  Created by Richard Dzubko on 14.02.2025.
//
//

import Foundation
import CoreData


extension CartItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CartItem> {
        return NSFetchRequest<CartItem>(entityName: "CartItem")
    }

    @NSManaged public var itemId: Int64
    @NSManaged public var title: String?
    @NSManaged public var price: Int64
    @NSManaged public var imageUrl: URL?
    @NSManaged public var quantity: Int64

}

extension CartItem : Identifiable {

}
