//
//  URLRequestConvertable.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import Foundation


// MARK: - Router

protocol URLRequestConvertable {
    var endpoint: String { get }
    
    var method: URLMethod { get }
    
    var body: Data? { get }
    
    var queryParameters: [URLQueryItem] { get }
    
    func convertToRequest() throws -> URLRequest
}

extension URLRequestConvertable {
    func convertToRequest() throws -> URLRequest {
        let urlString = "\(Constants.baseUrl)\(endpoint)"
        let requestUrl = URL(string: urlString)
        precondition(requestUrl != nil, "Invalid url: \(urlString)")
        
        var urlComponents = URLComponents(url: requestUrl!, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryParameters
        
        guard let url = urlComponents.url else {
            // The error may arise due to user input
            print("Invalid request url: \(urlComponents.debugDescription)")
            throw NetworkError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        return request
    }
        
}
