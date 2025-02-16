//
//  SearchRepositories.swift
//  avito2025
//
//  Created by Richard Dzubko on 14.02.2025.
//

import Foundation

protocol SearchRepositoryObserver {
    func onSearchHistoryChanged()
}

class SearchRepository {
    private let dbService: DBService
    static private let pagination = Pagination(offset: 0, limit: 5)
    
    init(dbService: DBService) {
        self.dbService = dbService
    }
    
    var observer: SearchRepositoryObserver?
    
    func getLastSavedQueries() -> [LastSearchQuery] {
        let sort = NSSortDescriptor(key: #keyPath(LastSearchQuery.lastAccess), ascending: false)
        
        let lastSavedEntities = try? dbService.get(
            all: LastSearchQuery.self,
            sort: sort,
            pagination: SearchRepository.pagination
        )
        
        return lastSavedEntities ?? []
    }
    
    func saveQuery(_ query: ProductFilters) throws {
        if query.title == nil || query.title!.isEmpty {
            return
        }
        
        let item = try? dbService.get(one: query)
        
        item == nil ? try dbService.add(query)
                    : try dbService.update(query)
        
        observer?.onSearchHistoryChanged()
    }
}
