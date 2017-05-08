//
//  RecipesTableViewController.swift
//  MyRecipe
//
//  Created by Toma Radu-Petrescu on 16/04/2017.
//  Copyright © 2017 Toma Radu-Petrescu. All rights reserved.
//

import UIKit

class RecipesTableViewController: UITableViewController, UISearchBarDelegate {
    
    private var refreshing = false
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private var recipes = [Recipe]() {
        didSet {
            if searchController.isActive == true {
                recipeRequest()
            }
            else {
                if refreshing == false {
                    tableView.reloadData()
                }
            }
        }
    }
    
    private var searchRecipes = [Recipe]() {
        didSet {
            tableView.reloadData()
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
        
        recipeRequest()
    }
    
    private func setupSearchBar() {
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a recipe"
        
        searchController.searchBar.barTintColor = navigationController?.navigationBar.barTintColor
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.isTranslucent = false
        
        searchController.searchBar.backgroundColor = UIColor.black
        
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.refreshControl?.addTarget(self, action: #selector(RecipesTableViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        refreshing = true
        recipes = [Recipe]()
        pageNumber = 1
        requestManager.requestRecipes(forPage: pageNumber) { (result, error) in
            if error == nil {
                print("made list request for page \(self.pageNumber)")
                if let result = result {
                    self.recipes += result
                    self.pageNumber = self.pageNumber + 1
                }
            }
            else {
                print(error!)
            }
            self.refreshing = false
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
                        if searchController.isActive == true {
                            vc.recipe = searchRecipes[indexPath.row]
                        }
                        else {
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
        
        if searchController.isActive == false {
            if indexPath.row < recipes.count && recipes.count != 0 {
                cell.loadRecipePreview(recipe: recipes[indexPath.row])
                if nearRowUpdate(currentIndexPath: indexPath) {
                    recipeRequest()
                }
            }
        }
        else {
            cell.loadRecipePreview(recipe: searchRecipes[indexPath.row])
            if nearSearchRowUpdate(currentIndexPath: indexPath) {
                recipeSearchRequest(query: searchController.searchBar.text!)
            }
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchRecipes.count
        }
        else {
            return recipes.count
        }
    }
    
    private func recipeRequest() {
        requestManager.requestRecipes(forPage: pageNumber) { (result, error) in
            if error == nil {
                print("made list request for page \(self.pageNumber)")
                if let result = result {
                    self.recipes += result
                    self.pageNumber = self.pageNumber + 1
                }
            }
            else {
                print(error!)
            }
        }
    }
    
    private func recipeSearchRequest(query: String) {
        requestManager.requestRecipes(forQuery: query, forPage: pageNumberSearch) { (result, error) in
            if error == nil {
                print("made search request for page \(self.pageNumberSearch), \(query)")
                self.searchRecipes += result!
                self.pageNumberSearch = self.pageNumberSearch + 1
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        pageNumberSearch = 1
        pageNumber = 1
        recipes = [Recipe]()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchRecipes = [Recipe]()
        pageNumberSearch = 1
        pageNumber = 1
        recipeSearchRequest(query: searchBar.text!)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tableView.isScrollEnabled = true
        tableView.allowsSelection = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
