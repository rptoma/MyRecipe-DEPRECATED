//
//  FavoriteTableViewCell.swift
//  MyRecipe
//
//  Created by Toma Radu-Petrescu on 03/05/2017.
//  Copyright © 2017 Toma Radu-Petrescu. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initLabels(recipe: Recipe?) {
        nameLabel.text = recipe?.name
    }
    
}
