//
//  CenterFocusScrollView.swift
//  TestProject
//
//  Created by Admin on 16/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

protocol CenterFocusViewDelegate {
    func selectedOneOption(_ view: CenterFocusView, nIdx: Int)
}

class CenterFocusView: UIView, UIScrollViewDelegate, TextSubViewDelegate, TextIconSubViewDelegate {
    var actionDelegate: CenterFocusViewDelegate? = nil
    
    var scrollView: UIScrollView? = nil
    var cellWidth: CGFloat = 0.0
    
    var titles: [String] = []
    var activeIcons: [String] = []
    var unActiveIcons: [String] = []

    var selectIdentifier: UIView? = nil
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
    }
    
    init(_ frame: CGRect, _ cellWidth: CGFloat, _ titles: [String], _ strUnit: String, _ nSelectedIdx: Int = 0, _ isRectIdentifier: Bool = true) {
        super.init(frame: frame)
        
        self.titles = titles
        
        self.cellWidth = cellWidth
        self.backgroundColor = UIColor.clear

        if (isRectIdentifier) {
            self.selectIdentifier = UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.bounds.height, height: self.bounds.height)))
            self.selectIdentifier?.center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
            self.selectIdentifier?.backgroundColor = UIColor.clear
            self.addSubview(self.selectIdentifier!)
            InterfaceManager.makeRadiusControl(self.selectIdentifier!, cornerRadius: 0.0, withColor: UIColor.white, borderSize: 2.0)
        } else {
            self.selectIdentifier = UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.bounds.height + 10.0, height: 2.0)))
            self.selectIdentifier?.center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height - 6.0)
            self.selectIdentifier?.backgroundColor = UIColor.white
            self.addSubview(self.selectIdentifier!)
        }

        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView?.backgroundColor = UIColor.clear
        self.scrollView?.delegate = self
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.showsVerticalScrollIndicator = false
        //self.scrollView?.isScrollEnabled = false
        self.scrollView?.decelerationRate = UIScrollViewDecelerationRateFast
        self.addSubview(self.scrollView!)
        
        let initialOffset: CGFloat = self.bounds.width / 2.0 - cellWidth / 2.0
        var cellOffset: CGFloat = initialOffset
        for nIdx in 0..<titles.count {
            let rect = CGRect(x: cellOffset, y: 2.0, width: cellWidth, height: self.bounds.height - 4.0)
            let subView = TextSubView(rect, "\(titles[nIdx])\(strUnit)", nIdx)
            subView.delegate = self
            subView.tag = 10 + nIdx
            self.scrollView?.addSubview(subView)
            
            subView.setActive(false)
            if (nIdx == nSelectedIdx) {
                subView.setActive(true)
            }
            
            cellOffset += cellWidth
        }
        
        cellOffset = cellOffset - cellWidth / 2.0 + self.bounds.width / 2.0
        self.scrollView?.contentSize = CGSize(width: cellOffset, height: self.bounds.height)
        self.scrollView?.setContentOffset(CGPoint(x: cellWidth * CGFloat(nSelectedIdx), y: 0.0), animated: false)
    }
    
    init(_ frame: CGRect, _ cellWidth: CGFloat, _ titles: [String], _ activeIcons: [String], _ unactiveIcons: [String], _ nSelectedIdx: Int) {
        super.init(frame: frame)
        
        self.titles = titles
        self.activeIcons = activeIcons
        self.unActiveIcons = unactiveIcons
        
        self.cellWidth = cellWidth
        self.backgroundColor = UIColor.clear
        
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView?.backgroundColor = UIColor.clear
        self.scrollView?.delegate = self
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.showsVerticalScrollIndicator = false
        //self.scrollView?.isScrollEnabled = false
        self.scrollView?.decelerationRate = UIScrollViewDecelerationRateFast
        self.addSubview(self.scrollView!)
        
        let initialOffset: CGFloat = self.bounds.width / 2.0 - cellWidth / 2.0
        var cellOffset: CGFloat = initialOffset
        for nIdx in 0..<titles.count {
            let rect = CGRect(x: cellOffset, y: 2.0, width: cellWidth, height: self.bounds.height - 4.0)
            let subView = TextIconSubView(rect, titles[nIdx], activeIcons[nIdx], unactiveIcons[nIdx], nIdx)
            subView.delegate = self
            subView.tag = 10 + nIdx
            self.scrollView?.addSubview(subView)
            
            subView.setActive(false)
            if (nIdx == nSelectedIdx) {
                subView.setActive(true)
            }
            
            cellOffset += cellWidth
        }
        
        cellOffset = cellOffset - cellWidth / 2.0 + self.bounds.width / 2.0
        self.scrollView?.contentSize = CGSize(width: cellOffset, height: self.bounds.height)
        self.scrollView?.setContentOffset(CGPoint(x: cellWidth * CGFloat(nSelectedIdx), y: 0.0), animated: false)
    }
    
    func tappedTextSubView(_ index: Int) {
        setAllSubViewAsUnactive()
        
        if let subView = self.scrollView?.viewWithTag(10 + index) {
            (subView as! TextSubView).setActive(true)

            self.scrollView?.setContentOffset(CGPoint(x: self.cellWidth * CGFloat(index), y: 0.0), animated: true)
            
            self.actionDelegate?.selectedOneOption(self, nIdx: index)
        }
    }
    
    func tappedTextIconSubView(_ index: Int) {
        setAllSubViewAsUnactive()
        
        if let subView = self.scrollView?.viewWithTag(10 + index) {
            (subView as! TextIconSubView).setActive(true)
            
            self.scrollView?.setContentOffset(CGPoint(x: self.cellWidth * CGFloat(index), y: 0.0), animated: true)
            
            self.actionDelegate?.selectedOneOption(self, nIdx: index)
        }
    }

    func setAllSubViewAsUnactive() {
        for nIdx in 0..<self.titles.count {
            if let subView = self.scrollView?.viewWithTag(10 + nIdx) {
                if subView is TextSubView {
                    (subView as! TextSubView).setActive(false)
                } else if subView is TextIconSubView {
                    (subView as! TextIconSubView).setActive(false)
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            print("end scrolling")
            self.stopScrolling(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("end scrolling")
        self.stopScrolling(scrollView)
    }
    
    func stopScrolling(_ scrollView: UIScrollView) {
        var nSelectedIdx: Int = -1
        let offsetX = scrollView.contentOffset.x
        
        for nIdx in 0..<self.titles.count {
            if let subView = self.scrollView?.viewWithTag(10 + nIdx) {
                if (subView.frame.contains(CGPoint(x: offsetX + scrollView.bounds.width / 2.0, y: 10))) {
                    nSelectedIdx = nIdx
                }
            }
        }
        
        print(nSelectedIdx)
        
        self.scrollView?.setContentOffset(CGPoint(x: self.cellWidth * CGFloat(nSelectedIdx), y: 0.0), animated: true)
        
        setAllSubViewAsUnactive()
        
        if let subView = self.scrollView?.viewWithTag(10 + nSelectedIdx) {
            if subView is TextSubView {
                (subView as! TextSubView).setActive(true)
            } else if subView is TextIconSubView {
                (subView as! TextIconSubView).setActive(true)
            }
        }
        
        self.actionDelegate?.selectedOneOption(self, nIdx: nSelectedIdx)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
