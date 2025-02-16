//
//  Pagination.swift
//  avito2025
//
//  Created by Richard Dzubko on 13.02.2025.
//

import Foundation

struct Pagination: URLQueryConvertable {
    func convertToQueryParams() -> [URLQueryItem] {
        [
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
        ]
    }
    
    let offset: Int
    let limit: Int
    
    init (offset: Int = 0, limit: Int = pageSize) {
        self.offset = offset
        self.limit = limit
    }
    
    static let pageSize = 12
    
    func next() -> Pagination {
        Pagination(offset: offset + Pagination.pageSize, limit: limit)
    }
}
