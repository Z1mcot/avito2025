//
//  CartViewController+TableView.swift
//  avito2025
//
//  Created by Richard Dzubko on 15.02.2025.
//

import UIKit

extension CartViewController: UITableViewDataSource {
    func setupTableView() {
        cartItemsTable.register(CartItemCell.nib, forCellReuseIdentifier: CartItemCell.nibIdentifier)
        
        cartItemsTable.estimatedRowHeight = 220
        
        cartItemsTable.dataSource = self
        cartItemsTable.delegate = self
        cartItemsTable.dragDelegate = self
        cartItemsTable.dragInteractionEnabled = true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch status {
        case .loaded(let items), .ready(let items):
            return items.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.nibIdentifier, for: indexPath) as! CartItemCell
        
        switch status {
        case .loaded(let items), .ready(let items):
            let item = items[indexPath.row]
            cell.injectDependencies(item: item, repository: cartRepository)
        default:
            break
        }
        
        return cell
    }
}

extension CartViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch status {
        case .loaded(let items), .ready(let items):
            status = .navigating(Int(items[indexPath.row].itemId))
            performSegue(withIdentifier: ItemCardViewController.segueFromCartId, sender: self)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        switch status {
        case .loaded(let items), .ready(let items):
            var items = items
            let mover = items.remove(at: sourceIndexPath.row)
            items.insert(mover, at: destinationIndexPath.row)
            
            try? cartRepository.movePosition(item: items[sourceIndexPath.row], to: destinationIndexPath.row)
            
            status = .ready(items)
        default:
            break
        }
        
    }
    
}

extension CartViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        
        switch status {
        case .loaded(let items), .ready(let items):
            let item = items[indexPath.row]
            dragItem.localObject = item
        default:
            break
        }
        
        return [dragItem]
    }
}
