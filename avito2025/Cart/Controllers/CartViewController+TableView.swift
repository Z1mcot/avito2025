//
//  CartViewController+TableView.swift
//  avito2025
//
//  Created by Richard Dzubko on 15.02.2025.
//

import UIKit

extension CartViewController: UITableViewDataSource {
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
        performSegue(withIdentifier: ItemCardViewController.segueFromCartId, sender: self)
    }
    
}
