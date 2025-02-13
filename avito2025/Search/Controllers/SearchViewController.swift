//
//  ViewController.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import UIKit

fileprivate enum SearchStatus {
    case empty
    case loading
    case loaded([Product])
    case error(Error)
}

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var productsCollection: UICollectionView!
    
    private var filters: ProductFilters!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProductCollection()
        setupSearchBar()
    }

    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.setImage(UIImage(systemName: "slider.horizontal.3"), for: .bookmark, state: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier{
        case FilterViewController.segueId:
            guard let filterVC = segue.destination as? FilterViewController else {
                fatalError("Wrong destination view controller")
            }
//            filterVC.setFilters(filters)
            
        default:
            break
        }
    }

}

extension SearchViewController: UISearchBarDelegate {

   func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
       performSegue(withIdentifier: FilterViewController.segueId, sender: self)
   }

}


