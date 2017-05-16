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
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.shadowColor = UIColor(red: 100/255.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.5
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.5)
    }
    func pressAnimation(){
        
        self.layer.shadowColor = UIColor(red: 180/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1.0).cgColor
        let when = DispatchTime.now() + 1.0/2
        DispatchQueue.main.asyncAfter(deadline: when){
            self.layer.shadowColor = UIColor(red: 100/255.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        }
//        self.layer.shadowOpacity = 0.0
//        let x = self.frame.origin.x
//        let y = self.frame.origin.y
//        self.frame.origin = CGPoint(x: x, y: y+2.0)
//        let when = DispatchTime.now() + 1.0/2
//        DispatchQueue.main.asyncAfter(deadline: when){
//             self.layer.shadowOpacity = 1.0
//        }
    }
}
