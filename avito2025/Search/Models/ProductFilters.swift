//
//  ProductFilters.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import Foundation

struct ProductFilters: URLQueryConvertable {
    let title: String?
    
    let targetPrice: Int?
    
    let minPrice: Int
    let maxPrice: Int?
    
    let category: Int?
    
    
    
    init(title: String?, targetPrice: Int?, category: Int?) {
        self.title = title
        
        self.targetPrice = targetPrice
        
        self.minPrice = 0
        self.maxPrice = nil
        
        self.category = category
    }
    
    init(title: String?, maxPrice: Int?, category: Int?, minPrice: Int = 0) {
        self.title = title
        
        self.targetPrice = nil
        
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        
        self.category = category
    }
    
    
    func convertToQueryParams() -> [URLQueryItem] {
        var parameters: [URLQueryItem] = []
        
        if let title = title {
            parameters.append(URLQueryItem(name: "title", value: title))
        }
        
        assert(targetPrice == nil || maxPrice == nil, "Cannot specify both targetPrice and price range")
        
        
        if let targetPrice = targetPrice {
            parameters.append(URLQueryItem(name: "price", value: "\(targetPrice)"))
        } else if let maxPrice = maxPrice {
            parameters.append(URLQueryItem(name: "min_price", value: "\(minPrice)"))
            parameters.append(URLQueryItem(name: "max_price", value: "\(maxPrice)"))
        }
        
        if let category = category {
            parameters.append(URLQueryItem(name: "categoryId", value: "\(category)"))
        }
        
        
        return parameters
    }
}
