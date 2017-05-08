//
//  RecipeTableViewCell.swift
//  MyRecipe
//
//  Created by Toma Radu-Petrescu on 17/04/2017.
//  Copyright © 2017 Toma Radu-Petrescu. All rights reserved.
//

import UIKit
import Kingfisher

class RecipeTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var delimiterLabel: UILabel!
    
    var uid: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        nameLabel.layer.shadowOpacity = 0.5
        nameLabel.layer.shadowRadius = 1.5
        nameLabel.layer.shouldRasterize = true
        nameLabel.layer.rasterizationScale = UIScreen.main.scale
        
        difficultyLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        difficultyLabel.layer.shadowOpacity = 0.5
        difficultyLabel.layer.shadowRadius = 1.5
        difficultyLabel.layer.shouldRasterize = true
        difficultyLabel.layer.rasterizationScale = UIScreen.main.scale
        
        durationLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        durationLabel.layer.shadowOpacity = 0.5
        durationLabel.layer.shadowRadius = 1.5
        durationLabel.layer.shouldRasterize = true
        durationLabel.layer.rasterizationScale = UIScreen.main.scale
        
        delimiterLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        delimiterLabel.layer.shadowOpacity = 0.5
        delimiterLabel.layer.shadowRadius = 1.5
        delimiterLabel.layer.shouldRasterize = true
        delimiterLabel.layer.rasterizationScale = UIScreen.main.scale
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func loadImage(fromRecipe recipe: Recipe) {
        if let imgUrl = recipe.icon_image {
            if let url = URL(string: imgUrl) {
                let resource = ImageResource(downloadURL: url, cacheKey: nil)
                let processor = BlurImageProcessor(blurRadius: 4.1)
                backgroundImageView.kf.indicatorType = .activity
                backgroundImageView.kf.setImage(with: resource, placeholder: nil, options: [.processor(processor)], progressBlock: nil, completionHandler: nil)
            }
        }
        else {
            backgroundImageView.image = UIImage(named: Base.DEFAULT_IMAGE_PATH)?.kf.blurred(withRadius: CGFloat(4.1))
        }
    }
    
    public func loadRecipePreview(recipe: Recipe) {
        nameLabel.text = recipe.name
        durationLabel.text = "~" + TimeConverter.getTime(from: recipe.duration ?? 0)
        difficultyLabel.text = recipe.difficulty
        uid = recipe.uid
        loadImage(fromRecipe: recipe)
    }
    
}
