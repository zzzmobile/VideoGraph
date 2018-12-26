//
//  TextSubView.swift
//  TestProject
//
//  Created by Admin on 16/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

protocol TextSubViewDelegate {
    func tappedTextSubView(_ index: Int)
}

class TextSubView: UIView {
    var delegate: TextSubViewDelegate? = nil
    
    var m_lblTitle: UILabel? = nil
    var m_nIndex: Int = -1
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
    }

    init(_ frame: CGRect, _ title: String, _ index: Int) {
        super.init(frame: frame)
        
        self.m_nIndex = index
        
        self.backgroundColor = UIColor.clear

        self.m_lblTitle = UILabel(frame: self.bounds)
        self.m_lblTitle?.font = UIFont.systemFont(ofSize: 14.0)
        self.m_lblTitle?.text = title
        self.m_lblTitle?.textColor = UIColor.lightGray
        self.m_lblTitle?.textAlignment = .center
        self.addSubview(self.m_lblTitle!)
        
        let button = UIButton(frame: self.bounds)
        button.backgroundColor = UIColor.clear
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        self.addSubview(button)
    }
    
    func setActive(_ isActive: Bool) {
        self.m_lblTitle?.textColor = isActive ? UIColor.black : UIColor.lightGray
    }
    
    @objc func tappedButton() {
        self.delegate?.tappedTextSubView(self.m_nIndex)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
