//
//  TextViewExtension.swift
//  Karmus
//
//  Created by VironIT on 9/2/22.
//

import UIKit

extension UITextView {
    
    func startSettings(){
        self.text = "Не указано"
        self.textColor = UIColor.darkGray
    }
    
    var fixedText: String? {
        
        guard let color = self.textColor else{
            return nil
        }
        return color == .darkGray ? "" : self.text
    }
    
}


