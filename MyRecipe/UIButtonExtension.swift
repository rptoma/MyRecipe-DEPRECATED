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
}
