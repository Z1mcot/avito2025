//
//  SearchRepositories.swift
//  avito2025
//
//  Created by Richard Dzubko on 14.02.2025.
//

import Foundation

class SearchRepository {
    private let dbService: DBService
    static private let pagination = Pagination(offset: 0, limit: 5)
    
    init(networkService: NetworkService, dbService: DBService) {
        self.dbService = dbService
    }
    
    func getLastSavedQueries() -> [ProductFilters] {
        let sort = NSSortDescriptor(key: #keyPath(LastSearchQuery.lastAccess), ascending: false)
        
        let lastSavedEntities = try? dbService.get(
            all: LastSearchQuery.self,
            sort: sort,
            pagination: SearchRepository.pagination
        )
        
        return lastSavedEntities?.map { ProductFilters.from(dbModel: $0) } ?? []
    }
    
    func saveQuery(_ query: ProductFilters) throws {
        let item = try? dbService.getById(query)
        
        item == nil ? try dbService.add(query)
                    : try dbService.update(query)
    }
}
