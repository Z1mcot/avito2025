//
//  NetworkService.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import Foundation

enum NetworkError : Error {
    case badResponse
    case invalidUrl
    case serverError
    case authorizationError
    case invalidModel
}

class NetworkService {
    private let session = URLSession.shared
    
    private func handleResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
        
        switch httpResponse.statusCode {
        case 400...499:
            throw NetworkError.authorizationError
        case 500...599:
            throw NetworkError.serverError
        default:
            return
        }
    }
    
    func fetch(request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        
        try handleResponse(response)
        
        return data
    }
}
