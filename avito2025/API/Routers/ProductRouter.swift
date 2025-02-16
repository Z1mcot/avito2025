//
//  ProductRouter.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import Foundation

enum ProductRouter: URLRequestConvertable {
    case getProducts(pagination: Pagination, filters: ProductFilters)
    case getProductById(id: Int)
    
    var endpoint: String {
        switch self {
        case .getProducts:
            "/products"
        case .getProductById(let id):
            "/products/\(id)"
        }
    }
    
    var method: URLMethod {
        switch self {
        case .getProducts, .getProductById(_):
            return .get
        }
    }
    
    var body: Data? {
        switch self {
        default:
            return nil
        }
    }
    
    var queryParameters: [URLQueryItem] {
        switch self {
        case .getProducts(let pagination, let filters):
            let p = filters.convertToQueryParams() + pagination.convertToQueryParams()
            return p
        default:
            return []
        }
    }    
}
