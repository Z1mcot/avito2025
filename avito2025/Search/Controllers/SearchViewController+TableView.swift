//
//  SearchViewController+TableView.swift
//  avito2025
//
//  Created by Richard Dzubko on 16.02.2025.
//

import UIKit

extension SearchViewController: UITableViewDataSource {
    func setupTableView() {
        searchHistory.register(SearchItem.nib, forCellReuseIdentifier: SearchItem.reuseIdentifier)
        searchHistory.dataSource = self
        searchHistory.delegate = self 
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lastQueries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchItem.reuseIdentifier, for: indexPath) as! SearchItem
        
        cell.injectDependencies(lastQueries[indexPath.row], categoriesLookupTable: categoriesLookupTable)
        
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let query = lastQueries[indexPath.row]
        
        let filtersModel = ProductFilters.from(dbModel: query)
        try? searchRepository.saveQuery(filtersModel)
        
        view.endEditing(true)
        searchBar.text = filtersModel.title
        canFetchMore = true
        status = .loading(filtersModel)
    }
}

extension SearchViewController: SearchRepositoryObserver {
    func onSearchHistoryChanged() {
        fetchLastQueries()
        searchHistory.reloadData()
    }
}
