//
//  LastSearchQuery+CoreDataProperties.swift
//  avito2025
//
//  Created by Richard Dzubko on 14.02.2025.
//
//

import Foundation
import CoreData


extension LastSearchQuery {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastSearchQuery> {
        return NSFetchRequest<LastSearchQuery>(entityName: "LastSearchQuery")
    }

    @NSManaged public var searchQuery: String?
    @NSManaged public var lastAccess: Date?
    @NSManaged public var categoryId: Int64
    @NSManaged public var targetPrice: Int64
    @NSManaged public var minPrice: Int64
    @NSManaged public var maxPrice: Int64

}

extension LastSearchQuery : Identifiable {

}
