//
//  MyProjectHeaderView.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

protocol MyProjectHeaderViewDelegate {
    func tappedDeleteButton()
}

class MyProjectHeaderView: GSKStretchyHeaderView {
    var delegate: MyProjectHeaderViewDelegate? = nil
    
    @IBOutlet weak var m_imgThumbnail: UIImageView!
    @IBOutlet weak var m_lblTitle: UILabel!
    @IBOutlet weak var m_btnDelete: UIButton!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = UIColor.white
        self.expansionMode = .immediate
        self.minimumContentHeight = TheInterfaceManager.checkiPhoneX() ? 44.0 : 20.0
        
        InterfaceManager.addGlowEffect(self.m_btnDelete, color: UIColor.white, radius: 0.0)
    }
    
    @IBAction func actionDelete(_ sender: Any) {
        self.delegate?.tappedDeleteButton()
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        var alphaValue = CGFloatTranslateRange(stretchFactor, 0.2, 0.8, 0, 1)
        alphaValue = max(0, min(1, alphaValue))
        
        self.m_imgThumbnail.alpha = alphaValue
        //ssself.m_lblTitle.alpha = alphaValue
    }
}
