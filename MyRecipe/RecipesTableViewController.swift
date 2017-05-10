//
//  RecipesTableViewController.swift
//  MyRecipe
//
//  Created by Toma Radu-Petrescu on 16/04/2017.
//  Copyright © 2017 Toma Radu-Petrescu. All rights reserved.
//

import UIKit

class RecipesTableViewController: UITableViewController, UISearchBarDelegate {
    
    enum Table {
        case recent
        case search
    }
    
    var currentTable = Table.recent
    
    private var refreshing = false
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private var recipes = [Recipe]() {
        didSet {
            if refreshing == false {
                tableView.reloadData()
            }
        }
    }
    
    private var searchRecipes = [Recipe]() {
        didSet {
            if refreshing == false {
                tableView.reloadData()
            }
        }
    }
    
    private let requestManager = RequestManager()
    
    private var pageNumber: Int!
    private var pageNumberSearch: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        setupTableView()
        setupSearchBar()
        
        pageNumber = 1
        pageNumberSearch = 1
        
        recipeRequest(completionHandler: nil)
    }
    
    private func setupSearchBar() {
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a recipe"
        
        searchController.searchBar.barTintColor = navigationController?.navigationBar.barTintColor
        searchController.searchBar.tintColor = navigationController?.navigationBar.barTintColor
        searchController.searchBar.isTranslucent = false
        
        searchController.searchBar.backgroundColor = UIColor.black
        
        let cancelButtonAttributes: [String: AnyObject] = [NSForegroundColorAttributeName: UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)
        
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func setupRefreshControl() {
        self.refreshControl?.addTarget(self, action: #selector(RecipesTableViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
    }
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        setupRefreshControl()
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        refreshing = true
        recipes = [Recipe]()
        pageNumber = 1
        recipeRequest() { (error) in
            refreshControl.endRefreshing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Recipe Detail":
                if let indexPath = tableView.indexPath(for: sender as! RecipeTableViewCell) {
                    print(indexPath.row)
                    if let vc = segue.destination as? RecipeDetailViewController {
                        //print(indexPath.row)
                        if currentTable == .search {
                            vc.recipe = searchRecipes[indexPath.row]
                        }
                        else if currentTable == .recent {
                            vc.recipe = recipes[indexPath.row]
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    private func nearRowUpdate(currentIndexPath indexPath: IndexPath) -> Bool {
        return indexPath.row == recipes.count - Base.NUMBER_OF_ROWS_BEFORE_UPDATE
    }
    
    private func nearSearchRowUpdate(currentIndexPath indexPath: IndexPath) -> Bool {
        return indexPath.row == searchRecipes.count - Base.NUMBER_OF_ROWS_BEFORE_UPDATE
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RecipeTableViewCell
        
        if currentTable == .recent {
            if indexPath.row < recipes.count && recipes.count != 0 {
                cell.loadRecipePreview(recipe: recipes[indexPath.row])
                if nearRowUpdate(currentIndexPath: indexPath) {
                    recipeRequest(completionHandler: nil)
                }
            }
        }
        else  if currentTable == .search {
            if refreshing == false {
                cell.loadRecipePreview(recipe: searchRecipes[indexPath.row])
                if nearSearchRowUpdate(currentIndexPath: indexPath) {
                    recipeSearchRequest(query: searchController.searchBar.text!, completionHandler: nil)
                }
            }
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentTable == .search {
            return searchRecipes.count
        }
        if currentTable == .recent{
            return recipes.count
        }
        return 0
    }
    
    private func recipeRequest(completionHandler: ((_ error: String?) -> ())?) {
        requestManager.requestRecipes(forPage: pageNumber) { (result, error) in
            if error == nil {
                print("made list request for page \(self.pageNumber)")
                if let result = result {
                    self.refreshing = false
                    self.recipes += result
                    self.pageNumber = self.pageNumber + 1
                }
            }
            else {
                print(error ?? "unknown error")
            }
            completionHandler?(error)
        }
    }
    
    private func recipeSearchRequest(query: String, completionHandler: ((_ error: String?) -> ())?) {
        requestManager.requestRecipes(forQuery: query, forPage: pageNumberSearch) { (result, error) in
            if error == nil {
                print("made search request for page \(self.pageNumberSearch), \(query)")
                self.refreshing = false
                self.searchRecipes += result!
                self.pageNumberSearch = self.pageNumberSearch + 1
            }
            else {
                print(error ?? "unknown error")
            }
            completionHandler?(error)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        pageNumberSearch = 1
        pageNumber = 1
        
        if currentTable != .recent {
            tableView.setContentOffset(CGPoint.init(x: 0, y: 0 - searchController.searchBar.bounds.maxY - ((navigationController?.navigationBar.bounds.maxY) ?? 0)), animated: false)
            recipes = [Recipe]()
            recipeRequest(completionHandler: nil)
            //tableView.reloadData()
        }
        
        currentTable = .recent
        
        self.refreshControl = UIRefreshControl()
        setupRefreshControl()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        currentTable = .search
        refreshing = true

        searchRecipes = [Recipe]()
        pageNumberSearch = 1
        pageNumber = 1
        
        tableView.setContentOffset(CGPoint.init(x: 0, y: -64), animated: true)
        
        recipeSearchRequest(query: searchBar.text!) { (error) in
            if error != nil {
                self.refreshing = false
                self.searchRecipes = [Recipe]()
            }
        }
        self.refreshControl = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
