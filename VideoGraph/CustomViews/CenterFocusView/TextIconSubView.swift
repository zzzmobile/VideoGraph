//
//  TextIconSubView.swift
//  TestProject
//
//  Created by Admin on 16/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

protocol TextIconSubViewDelegate {
    func tappedTextIconSubView(_ index: Int)
}

class TextIconSubView: UIView {
    var delegate: TextIconSubViewDelegate? = nil

    var m_lblTitle: UILabel? = nil
    var m_imgIcon: UIImageView? = nil
    
    var activeImage: UIImage? = nil
    var unactiveImage: UIImage? = nil
    
    var m_nIndex: Int = -1

    required convenience init(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
    }
    
    init(_ frame: CGRect, _ title: String, _ activeIcon: String, _ unactiveIcon: String, _ index: Int) {
        super.init(frame: frame)
        
        self.m_nIndex = index

        self.backgroundColor = UIColor.clear
        
        self.m_lblTitle = UILabel(frame: CGRect(x: 0, y: 0.0, width: self.bounds.width - 2.0, height: 16))
        self.m_lblTitle?.font = UIFont.systemFont(ofSize: 12.0)
        self.m_lblTitle?.text = title
        self.m_lblTitle?.textColor = UIColor.lightGray
        self.m_lblTitle?.textAlignment = .center
        self.addSubview(self.m_lblTitle!)
        
        self.activeImage = UIImage(named: activeIcon)
        self.unactiveImage = UIImage(named: unactiveIcon)
        
        self.m_imgIcon = UIImageView(frame: CGRect(x: (self.bounds.width - 40.0) / 2, y: self.bounds.height - 24, width: 40, height: 22))
        self.m_imgIcon?.backgroundColor = UIColor.clear
        self.m_imgIcon?.image = self.unactiveImage
        self.m_imgIcon?.contentMode = .scaleAspectFit
        self.addSubview(self.m_imgIcon!)
        
        let button = UIButton(frame: self.bounds)
        button.backgroundColor = UIColor.clear
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        self.addSubview(button)
    }
    
    func setActive(_ isActive: Bool) {
        self.m_lblTitle?.textColor = isActive ? UIColor.black : UIColor.lightGray
        self.m_lblTitle?.font = UIFont.systemFont(ofSize: isActive ? 14.0 : 12.0)
        
        self.m_imgIcon?.image = isActive ? self.activeImage : self.unactiveImage
    }
    
    @objc func tappedButton() {
        self.delegate?.tappedTextIconSubView(self.m_nIndex)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
