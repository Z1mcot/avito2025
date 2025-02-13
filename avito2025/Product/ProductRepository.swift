//
//  ProductRepository.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import Foundation
import UIKit

class ProductRepository {
    private let imageService: ImageService
    private let networkService: NetworkService
    
    init(
        imageService: ImageService,
        networkService: NetworkService
    ) {
        self.imageService = imageService
        self.networkService = networkService
    }
    
    func getProducts(pagination: Pagination, filters: ProductFilters) async throws -> [Product] {
        let route = ProductRouter.getProducts(pagination: pagination, filters: filters)
        let data = try await networkService.fetch(request: route.convertToRequest())
        
        do {
            let products = try JSONDecoder().decode([Product].self, from: data)
            return products
        } catch {
            throw NetworkError.badResponse
        }
    }
    
    func getProductImage(by urlString: String) async throws -> UIImage {
        try await imageService.getImage(from: urlString)
    }
}
