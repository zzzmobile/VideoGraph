//
//  FilterCell.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    @IBOutlet weak var m_imgView: UIImageView!
    
    func showFilteredImage(_ filterIdx: Int) {
        self.m_imgView.backgroundColor = UIColor.black
        
        self.m_imgView.image = TheVideoEditor.stillImage
        
        if (filterIdx > 0) {
            self.m_imgView.image = nil

            DispatchQueue.global(qos: .background).async {
                let filteredImage = TheVideoFilterManager.applyFilter(filterIdx, TheVideoEditor.stillImage!)
                DispatchQueue.main.async {
                    self.m_imgView.image = filteredImage
                }
            }
        }
    }
}
