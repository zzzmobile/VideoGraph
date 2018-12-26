//
//  ProjectCell.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

protocol ProjectCellDelegate {
    func tappedCreateNewVideo(_ cell: ProjectCell)
    func tappedPlayVideo(_ cell: ProjectCell)
}

class ProjectCell: UICollectionViewCell {
    var delegate: ProjectCellDelegate? = nil
    
    @IBOutlet weak var m_imgThumbnail: UIImageView!
    @IBOutlet weak var m_lblCreateNew: UILabel!
    
    @IBOutlet weak var m_btnCreateNew: UIButton!
    @IBOutlet weak var m_btnPlay: UIButton!
    
    func showInfo(_ bIsNewProject: Bool) {
        self.m_btnCreateNew.isHidden = true
        self.m_btnPlay.isHidden = true
        self.m_lblCreateNew.isHidden = true
        self.m_imgThumbnail.image = UIImage.init(named: "bwt-bg")
        
        if (bIsNewProject) {
            self.m_btnCreateNew.isHidden = false
            self.m_lblCreateNew.isHidden = false
        } else {
            self.m_btnPlay.isHidden = false
        }
    }
    
    @IBAction func actionCreateNew(_ sender: Any) {
        self.delegate?.tappedCreateNewVideo(self)
    }
    
    @IBAction func actionPlay(_ sender: Any) {
        self.delegate?.tappedPlayVideo(self)
    }
    
}
