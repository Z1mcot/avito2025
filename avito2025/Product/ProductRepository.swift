//
//  ProductRepository.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import Foundation
import UIKit

class ProductRepository {
    private let networkService: NetworkService
    private let dbService: DBService
    
    init(
        networkService: NetworkService,
        dbService: DBService
    ) {
        self.networkService = networkService
        self.dbService = dbService
    }
    
    private func sendRequest<Response: Decodable>(_ route: URLRequestConvertable, for returnType: Response.Type) async throws -> Response {
        
        let request = try route.convertToRequest()
        print(request.url?.absoluteString ?? "")
        let data = try await networkService.fetch(request: request)
        
        do {
            let products = try JSONDecoder().decode(returnType, from: data)
            return products
        } catch {
            throw NetworkError.badResponse
        }
    }
    
    func getProducts(pagination: Pagination, filters: ProductFilters) async throws -> [Product] {
        let route = ProductRouter.getProducts(pagination: pagination, filters: filters)
        return try await sendRequest(route, for: [Product].self)
    }
    
    func getProductById(_ id: Int) async throws -> Product {
        let route = ProductRouter.getProductById(id: id)
        var model = try await sendRequest(route, for: Product.self)
        
        let entity = try? dbService.getById(model) as? CartItem
        if entity != nil {
            model.set(newQuantity: Int(entity!.quantity))
        }
        
        return model
    }
    
    func getCategories() async throws -> [Category] {
        let route = CategoryRouter.getCategories
        return try await sendRequest(route, for: [Category].self)
    }
}
