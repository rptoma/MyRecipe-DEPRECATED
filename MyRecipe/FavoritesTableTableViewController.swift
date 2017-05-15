//
//  FavoritesTableTableViewController.swift
//  MyRecipe
//
//  Created by Toma Radu-Petrescu on 02/05/2017.
//  Copyright © 2017 Toma Radu-Petrescu. All rights reserved.
//

import UIKit

class FavoritesTableTableViewController: UITableViewController {

    private let coreDataManager = CoreDataManager()
    private let requestManager = RequestManager()
    private var favorites = [Favorite]()
    private var favorieRecipes = [Recipe?]()
    private var initialLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white
        coreDataManager.fetchFavorites { (result, error) in
            if let error = error {
                print(error)
            }
            else {
                favorites = result!
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favorites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FavoriteTableViewCell
        
        if initialLoad == true {
            requestManager.requestRecipePreview(forUID: favorites[indexPath.row].uid!) { (result, error) in
                if error == nil {
                    if let result = result {
                        DispatchQueue.main.async {
                            cell.indicatorView.stopAnimating()
                            cell.initLabels(recipe: result)
                        }
                    }
                }
                else {
                    print(error ?? "unknown error")
                }
                
                self.favorieRecipes.append(result)

                if indexPath.row == self.favorites.count - 1 {
                    self.initialLoad = false
                }
                
            }
        }
        else {
            cell.initLabels(recipe: favorieRecipes[indexPath.row])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FavoriteTableViewCell
        if favorieRecipes[indexPath.row] != nil {
            performSegue(withIdentifier: "Show Recipe Detail", sender: cell)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Recipe Detail":
                if let sender = sender as? FavoriteTableViewCell {
                    let indexPath = tableView.indexPath(for: sender)
                    if let indexPath = indexPath {
                        if let vc = segue.destination as? RecipeDetailViewController {
                            vc.recipe = favorieRecipes[indexPath.row]
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                tableView.beginUpdates()
                try coreDataManager.deleteFavorite(forUID: favorites[indexPath.row].uid!)
                favorites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            }
            catch {
                print("Delete error")
            }
            defer {
                tableView.endUpdates()
            }
        }
    }
}
