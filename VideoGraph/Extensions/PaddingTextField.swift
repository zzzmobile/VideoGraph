//
//  PaddingTextField.swift
//  VideoGraph
//
//  Created by Admin on 13/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class PaddingTextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10.0);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
