//
//  DBService.swift
//  avito2025
//
//  Created by Richard Dzubko on 14.02.2025.
//

import CoreData

enum DBError: Error {
    case itemNotFound
    case creationFailed
    case updateFailed
    case deleteFailed
}

class DBService {
    let container = NSPersistentContainer(name: "avito2025")
    
    init() {
        container.loadPersistentStores { description, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Generic methods
    func get<Entity: NSManagedObject>(all: Entity.Type, sort: NSSortDescriptor, pagination: Pagination? = nil) throws -> [Entity] {
        let fetchRequest = Entity.fetchRequest()
        
        if pagination != nil {
            fetchRequest.fetchLimit = pagination!.limit
            fetchRequest.fetchOffset = pagination!.offset
        }
        
        fetchRequest.sortDescriptors = [sort]
        
        let fetchedEntities = try container.viewContext.fetch(fetchRequest)
        
        return fetchedEntities as! [Entity]
    }
    
    func delete<Entity: NSManagedObject>(all: Entity.Type) throws {
        let fetchRequest = Entity.fetchRequest()
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try container.viewContext.execute(batchDeleteRequest)
        
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                throw DBError.deleteFailed
            }
        }
    }
    
    // MARK: - Product methods
    
    func getById(_ item: Product) throws -> NSManagedObject {
        let fetchRequest = CartItem.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "itemId == %d", item.id)
        
        let fetchedEntities = try container.viewContext.fetch(fetchRequest)
        
        guard let entity = fetchedEntities.first else {
            throw DBError.itemNotFound
        }
        
        return entity
    }
    
    func add(_ item: Product) throws {
        let entity = CartItem(context: container.viewContext)
        
        entity.itemId = Int64(item.id)
        entity.price = Int64(item.price)
        entity.title = item.title
        entity.imageUrl = URL(string: item.images.first ?? "")
        entity.quantity = Int64(item.quantity)
        
        let fetchRequest = CartItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "position", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let lastItem = try container.viewContext.fetch(fetchRequest).first
            entity.position = (lastItem?.position ?? 0) + 1
        } catch {
            entity.position = 0
        }
        
        do {
            try container.viewContext.save()
        } catch {
            throw DBError.creationFailed
        }
    }
    
    func update(_ item: Product) throws {
        let entity = try getById(item) as! CartItem
        
        entity.quantity = Int64(item.quantity)
        
        do {
            try container.viewContext.save()
        } catch {
            throw DBError.updateFailed
        }
    }
    
    func delete(_ item: Product) throws {
        let entity = try getById(item)
        
        container.viewContext.delete(entity)
        try container.viewContext.save()
    }
    
    // MARK: - CartItem methods
    func update(_ item: CartItem, newPosition: Int? = nil) throws {
        if let newPosition = newPosition,
           item.position != newPosition{
            let request = CartItem.fetchRequest()
            
            if item.position < newPosition {
                request.predicate = NSPredicate(format: "position > %d AND position <= %d", item.position, newPosition)
            } else {
                request.predicate = NSPredicate(format: "position >= %d AND position < %d", newPosition, item.position)
            }
            
            let affectedItems = try container.viewContext.fetch(request)
            
            for affectedItem in affectedItems {
                affectedItem.position += (newPosition > item.position) ? -1 : 1
            }
            
            item.position = Int64(newPosition)
        }
        
        do {
            try container.viewContext.save()
        } catch {
            throw DBError.updateFailed
        }
    }
    
    func delete(_ item: CartItem) throws {
        assert(item.quantity == 0)
        container.viewContext.delete(item)
        try container.viewContext.save()
    }
    
    // MARK: - SearchQueries methods
    
    func getById(_ query: ProductFilters) throws -> NSManagedObject {        
        guard let queryTitle = query.title else {
            throw DBError.itemNotFound
        }
        
        let fetchRequest = LastSearchQuery.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "searchQuery = %@", queryTitle)
        
        let fetchedEntities = try container.viewContext.fetch(fetchRequest)
        
        guard let entity = fetchedEntities.first else {
            throw DBError.itemNotFound
        }
        
        return entity
    }
    
    func add(_ query: ProductFilters) throws {
        let entity = LastSearchQuery(context: container.viewContext)
        
        entity.searchQuery = query.title
        entity.lastAccess = Date.now
        
        entity.categoryId = query.categoryId == nil ? -1 : Int64(query.categoryId!)
        
        if let targetPrice = query.targetPrice {
            entity.targetPrice = Int64(targetPrice)
        } else {
            if let minPrice = query.minPrice {
                entity.minPrice = Int64(minPrice)
            }
            if let maxPrice = query.maxPrice {
                entity.maxPrice = Int64(maxPrice)
            }
        }
        
        do {
            try container.viewContext.save()
        } catch {
            throw DBError.creationFailed
        }
    }
    
    // We should update only last access date, otherwise it would be a new query
    func update(_ query: ProductFilters) throws {
        let entity = try getById(query) as! LastSearchQuery
        
        entity.lastAccess = Date.now
        
        do {
            try container.viewContext.save()
        } catch {
            throw DBError.updateFailed
        }
    }
}
