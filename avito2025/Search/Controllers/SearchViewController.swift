//
//  ViewController.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import UIKit

enum SearchStatus {
    case initial
    case empty(ProductFilters)
    case loading(ProductFilters)
    case loaded([Product], ProductFilters)
    case error(Error, ProductFilters)
}

class SearchViewController: UIViewController {
    // MARK: dependencies
    var productRepository: ProductRepository!
    var cartRepository: CartRepository!
    var searchRepository: SearchRepository!
    
    
    // MARK: outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var productsCollection: UICollectionView!
    
    @IBOutlet weak var messageIcon: UIImageView!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var searchHistory: UITableView!
    
    // MARK: model
    private var searchText: String = ""
    var currentPage: Pagination!
    var selectedId: Int!
    var canFetchMore: Bool = true
    
    var savedThisQuery: Bool = false
    
    var cartLookupTable: [Int64: Int] = [:]
    var products: [Product] = []
    var categories: [Category] = []
    var categoriesLookupTable: [Int: String] = [:]
    
    var lastQueries: [LastSearchQuery] = []
    
    var status: SearchStatus = .initial {
        
        didSet {
            switch status {
                
            case .initial:
                fetchCategories()
                fetchCart()
            case .empty(_):
                handleEmptyState()
            case .loading(let filters):
                handleLoading(oldStatus: oldValue, currentFilters: filters)
            case .loaded(let newItems, let filters):
                updateContent(newItems, filters: filters)
            case .error(let error, _):
                handleError(error)
            }
        }
    }
    
    // MARK: ui setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDependencies()
        status = .initial
        
        setupProductCollection()
        setupSearchBar()
        setupTableView()
        
        let filters = ProductFilters(title: nil, maxPrice: nil, category: nil, minPrice: nil)
        currentPage = Pagination()
        
        status = .loading(filters)
    }

    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.setImage(UIImage(systemName: "slider.horizontal.3"), for: .bookmark, state: .normal)
        searchBar.setImage(UIImage(systemName: "slider.horizontal.3"), for: .bookmark, state: .disabled)
        searchBar.isEnabled = false
    }
    
    private func configureDependencies() {
        let networkService = NetworkService()
        let dbService = DBService()
        productRepository = ProductRepository(
            networkService: networkService,
            dbService: dbService
        )
        cartRepository = CartRepository(dbService: dbService)
        
        cartRepository.addObserver(self, id: self.hash)
        
        searchRepository = SearchRepository(dbService: dbService)
        
        searchRepository.observer = self
    }
    
    func fetchProducts(_ filters: ProductFilters) async {
        do {
            let products = try await productRepository.getProducts(
                pagination: currentPage,
                filters: filters
            )
            
            if products.isEmpty {
                status = .empty(filters)
                return
            }
            
            status = .loaded(products, filters)
        } catch {
            status = .error(error, filters)
        }
    }
    
// MARK: actions
    @IBAction func goToCart(_ sender: Any) {
        performSegue(withIdentifier: CartViewController.segueId, sender: self)
    }
    
    @IBAction func retrySearch(_ sender: Any) {
        guard case .error(_, let productFilters) = status else {
            return
        }
        
        status = .loading(productFilters)
    }
    
    
// MARK: segue preparations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case FilterViewController.segueId:
            prepareFilterSegue(segue)
        case ItemCardViewController.segueFromSearchId:
            prepareItemCardSegue(segue)
        case CartViewController.segueId:
            prepareCartSegue(segue)
        default:
            break
        }
    }
    
    private func prepareFilterSegue(_ segue: UIStoryboardSegue) {
        let filterVC = segue.destination as! FilterViewController
        
        switch status {
        case let .loaded(_, filters), let .empty(filters), let .error(_, filters):
            filterVC.injectDependecies(categories, filters: filters, delegate: self)
        default:
            assert(false)
        }
    }
    
    private func prepareItemCardSegue(_ segue: UIStoryboardSegue) {
        switch status {
        case let .loaded(_, filters):
            if !savedThisQuery && !filters.isEmpty {
                try? searchRepository.saveQuery(filters)
                savedThisQuery = true
            }
        default:
            break
        }
        
        let itemCardVC = segue.destination as! ItemCardViewController
        
        itemCardVC.injectDependecies(productId: selectedId, cartRepository: cartRepository, productRepository: productRepository)
    }
    
    private func prepareCartSegue(_ segue: UIStoryboardSegue) {
        let cartVC = segue.destination as! CartViewController
        
        cartVC.injectDependencies(cartRepository: cartRepository, productRepository: productRepository)
    }
}

// MARK: - UI Updates
extension SearchViewController {
    private func fetchCategories() {
        Task {
            let categories = try? await productRepository.getCategories()
            
            self.categories = categories ?? []
            
            for category in self.categories {
                categoriesLookupTable[category.id] = category.name
            }
        }
    }
    
    private func fetchCart() {
        let cart = cartRepository.getCart()
        cartLookupTable = [:]
        
        for item in cart {
            cartLookupTable[item.itemId] = Int(item.quantity)
        }
        
        var cartButtonTitle: String = ""
        var cartButtonImage = UIImage(systemName: "cart")
        
        if !cart.isEmpty {
            cartButtonTitle = "\(cart.count)"
            cartButtonImage = UIImage(systemName: "cart.fill")
        }
        
        cartButton.setTitle(cartButtonTitle, for: .normal)
        cartButton.setImage(cartButtonImage, for: .normal)
    }
    
    func fetchLastQueries() {
        let queries = searchRepository.getLastSavedQueries()
        lastQueries = queries
    }
    
    func handleLoading(oldStatus: SearchStatus, currentFilters: ProductFilters) {
        productsCollection.isHidden = false
        
        searchBar.isEnabled = false
        
        if case .loaded(_, let oldFilters) = oldStatus, oldFilters == currentFilters {
            currentPage = currentPage.next()
            productsCollection.isScrollEnabled = true
        } else {
            currentPage = Pagination()
            products = []
            productsCollection.reloadData()
            productsCollection.isScrollEnabled = false
        }
        
        Task {
            await fetchProducts(currentFilters)
        }
    }
    
    func updateContent(_ items: [Product], filters: ProductFilters) {
        searchBar.isEnabled = true
        
        productsCollection.isHidden = false
        
        let lastItemIdx = products.count
        products.append(contentsOf: items)
        
        if lastItemIdx == 0 {
            productsCollection.setContentOffset(.zero, animated: false)
            productsCollection.reloadData()
        } else {
            var newIndexPaths: [IndexPath] = []
            for idx in 0..<items.count {
                let newIndexPath = IndexPath(item: lastItemIdx + idx, section: 0)
                newIndexPaths.append(newIndexPath)
            }
            
            productsCollection.insertItems(at: newIndexPaths)
        }
        
        productsCollection.isScrollEnabled = true
    }
    
    func handleError(_ error: Error) {
        searchBar.isEnabled = true
        
        retryButton.isHidden = false
        messageIcon.image = UIImage(systemName: "exclamationmark.triangle.fill")
        messageText.text = "Something went wrong. Try searching again later"
        productsCollection.isHidden = true
    }
    
    func handleEmptyState() {
        searchBar.isEnabled = true
        
        if !products.isEmpty {
            canFetchMore = false
            return
        }
        
        retryButton.isHidden = true
        messageIcon.image = UIImage(systemName: "minus.magnifyingglass")
        messageText.text = "Your search yielded no results. Try again with different keywords."
        productsCollection.isHidden = true
    }
}

// MARK: - SearchBar Delegate
extension SearchViewController: UISearchBarDelegate {

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
       performSegue(withIdentifier: FilterViewController.segueId, sender: self)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        cartButton.isHidden = true
        
        searchHistory.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        cartButton.isHidden = false
        
        searchHistory.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        switch status {
        case let .loaded(_, filters), let .empty(filters), let .error(_, filters):
            var filters = filters
            filters.title = searchText
            canFetchMore = true
            savedThisQuery = false
            status = .loading(filters)
        default:
            return
        }
    }
}

// MARK: - Product & Filter Delegate

extension SearchViewController: CartObserver {
    func onCartCleared() {
        fetchCart()
    }
    
    func onItemAdded(_ newItem: Product) {
        fetchCart()
    }
    
    func onItemRemoved(_ removedItem: Product) {
        fetchCart()
    }
}

extension SearchViewController: ProductFilterSearchDelegate {
    func onFiltersChanged(filters: ProductFilters) {
        var filters = filters
        
        if !searchText.isEmpty {
            filters.title = searchText
        }
        savedThisQuery = false
        canFetchMore = true
        status = .loading(filters)
    }
}

