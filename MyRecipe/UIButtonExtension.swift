//
//  UIButtonExtension.swift
//  MyRecipe
//
//  Created by Toma Radu-Petrescu on 10/05/2017.
//  Copyright © 2017 Toma Radu-Petrescu. All rights reserved.
//

import Foundation

extension UIButton {
    func addTextSpacing() {
        if let textString = titleLabel?.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSKernAttributeName, value: -1.1, range: NSRange(location: 0, length: attributedString.length - 1))
            titleLabel?.attributedText = attributedString
        }
    }
    
    func addShadow(){
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.50).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
    }
}
