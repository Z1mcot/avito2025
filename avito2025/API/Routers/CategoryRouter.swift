//
//  CategoryRouter.swift
//  avito2025
//
//  Created by Richard Dzubko on 15.02.2025.
//

import Foundation

enum CategoryRouter: URLRequestConvertable {
    case getCategories
    case getCategoriesById(id: Int)
    
    var endpoint: String {
        switch self {
        case .getCategories:
            "/categories"
        case .getCategoriesById(let id):
            "/categories/\(id)"
        }
    }
    
    var method: URLMethod {
        switch self {
        case .getCategories, .getCategoriesById(_):
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
        default:
            return []
        }
    }
}
