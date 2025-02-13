//
//  ProductRouter.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import Foundation

enum ProductRouter: URLRequestConvertable {
    case getProducts(pagination: Pagination, filters: ProductFilters)
    
    var endpoint: String {
        switch self {
        case .getProducts:
            "/products"
        }
    }
    
    var method: URLMethod {
        switch self {
        case .getProducts:
            return .get
        }
    }
    
    var body: Data? {
        switch self {
        case .getProducts:
            return nil
        }
    }
    
    var queryParameters: [URLQueryItem] {
        switch self {
        case .getProducts(let pagination, let filters):
            let p = filters.convertToQueryParams() + pagination.convertToQueryParams()
            return p
        }
    }
}
