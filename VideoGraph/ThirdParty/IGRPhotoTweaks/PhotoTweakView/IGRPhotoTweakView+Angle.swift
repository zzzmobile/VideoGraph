//
//  IGRPhotoTweakView+Angle.swift
//  Pods
//
//  Created by Vitalii Parovishnyk on 4/26/17.
//
//

import Foundation

extension IGRPhotoTweakView {
    public func changedAngle(value: CGFloat) {
        // update masks
        self.highlightMask(true, animate: false)
        
        // update grids
        self.cropView.updateGridLines(animate: false)

        // rotate scroll view
        let radians = IGRRadianAngle.toRadians(90.0)

        self.angle = value
        self.scrollView.transform = CGAffineTransform(scaleX: (self.fliped ? -1.0 : 1.0), y: 1.0).rotated(by: self.angle - CGFloat(self.rotateCnt) * radians)

        self.updatePosition()
    }
    
    public func changedAngleBy90() {
        // update masks
        self.highlightMask(true, animate: false)
        
        // update grids
        self.cropView.updateGridLines(animate: false)
        
        self.rotateCnt += 1
        if (self.rotateCnt == 4) {
            self.rotateCnt = 0
        }
        
        // rotate scroll view
        let radians = IGRRadianAngle.toRadians(90.0)
        
        //self.angle -= radians
        //self.scrollView.transform = CGAffineTransform(rotationAngle: self.angle)
        self.scrollView.transform = CGAffineTransform(scaleX: (self.fliped ? -1.0 : 1.0), y: 1.0).rotated(by: self.angle - CGFloat(self.rotateCnt) * radians)

        self.updatePosition()
    }
    
    public func flip() {
        // update masks
        self.highlightMask(true, animate: false)
        
        // update grids
        self.cropView.updateGridLines(animate: false)
        
        // rotate & flip scroll view
        let radians = IGRRadianAngle.toRadians(90.0)

        self.fliped = !self.fliped
        UIView.transition(with: self.scrollView, duration: 0.6, options: (self.fliped ? .transitionFlipFromLeft : .transitionFlipFromRight), animations: {
            self.scrollView.transform = CGAffineTransform(scaleX: (self.fliped ? -1.0 : 1.0), y: 1.0).rotated(by: self.angle - CGFloat(self.rotateCnt) * radians)
        }) { (bCompleted) in
            if (bCompleted) {
                self.updatePosition()
                
                self.cropView.dismissGridLines()
                self.highlightMask(false, animate: false)
            }
        }
    }
    
    public func stopChangeAngle() {
        self.cropView.dismissGridLines()
        self.highlightMask(false, animate: false)
    }
}
