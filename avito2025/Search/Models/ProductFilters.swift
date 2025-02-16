//
//  ProductFilters.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import Foundation

struct ProductFilters: URLQueryConvertable, Equatable {
    var title: String?
    
    var targetPrice: Int?
    
    var minPrice: Int?
    var maxPrice: Int?
    
    var categoryId: Int?
    
    var isEmpty: Bool {
        return title == nil && targetPrice == nil && minPrice == nil && maxPrice == nil && categoryId == nil
    }
    
    init(title: String?, targetPrice: Int?, category: Int?) {
        self.title = title
        
        self.targetPrice = targetPrice
        
        self.minPrice = 0
        self.maxPrice = nil
        
        self.categoryId = category
    }
    
    init(title: String?, maxPrice: Int?, category: Int?, minPrice: Int?) {
        self.title = title
        
        self.targetPrice = nil
        
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        
        self.categoryId = category
    }
    
    
    func convertToQueryParams() -> [URLQueryItem] {
        var parameters: [URLQueryItem] = []
        
        if let title = title,
           !title.isEmpty {
            parameters.append(URLQueryItem(name: "title", value: title))
        }
        
        assert(targetPrice == nil || maxPrice == nil, "Cannot specify both targetPrice and price range")
        
        
        if let targetPrice = targetPrice {
            parameters.append(URLQueryItem(name: "price", value: "\(targetPrice)"))
        } else {
            if let minPrice = minPrice {
                parameters.append(URLQueryItem(name: "price_min", value: "\(minPrice)"))
            }
            
            if let maxPrice = maxPrice {
                parameters.append(URLQueryItem(name: "price_max", value: "\(maxPrice)"))
            }
        }
        
        if let category = categoryId {
            parameters.append(URLQueryItem(name: "categoryId", value: "\(category)"))
        }
        
        
        return parameters
    }
    
    static func from(dbModel: LastSearchQuery) -> ProductFilters {
        if dbModel.targetPrice == .zero {
            return ProductFilters(
                title: dbModel.searchQuery,
                maxPrice: dbModel.maxPrice == .zero ? nil : Int(dbModel.maxPrice),
                category: dbModel.categoryId == -1 ? nil : Int(dbModel.categoryId),
                minPrice: dbModel.maxPrice == .zero ? nil : Int(dbModel.minPrice)
            )
        }
        
        return ProductFilters(
            title: dbModel.searchQuery,
            targetPrice: dbModel.targetPrice == .zero ? nil : Int(dbModel.targetPrice),
            category: dbModel.categoryId == .zero ? nil : Int(dbModel.categoryId)
        )
    }
}
