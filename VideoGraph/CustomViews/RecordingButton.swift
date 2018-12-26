//
//  RecordingButton.swift
//  VideoGraph
//
//  Created by Admin on 16/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

protocol RecordingButtonDelegate {
    func finishedRecordingAnimation()
}
class RecordingButton: UIButton, CAAnimationDelegate {
    var delegate: RecordingButtonDelegate? = nil
    
    var circleLayer: CAShapeLayer? = nil
    var isRecording: Bool = false
    
    func createCircleLayer() {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width - 8.0)/2, startAngle: CGFloat(-1.0 * Double.pi / 2.0), endAngle: CGFloat(Double.pi * 2.0 - Double.pi / 2.0), clockwise: true)
        
        // Setup the CAShapeLayer with the path, colors, and line width
        circleLayer = CAShapeLayer()
        circleLayer?.path = circlePath.cgPath
        circleLayer?.fillColor = UIColor.clear.cgColor
        circleLayer?.strokeColor = UIColor.red.cgColor
        circleLayer?.lineWidth = 4.0
        
        // Don't draw the circle initially
        circleLayer?.strokeEnd = 0.0
        
        // Add the circleLayer to the view's layer's sublayers
        layer.addSublayer(circleLayer!)
    }
    
    func removeCirclelayer() {
        if (circleLayer != nil) {
            circleLayer!.removeFromSuperlayer()
            circleLayer = nil
        }
    }
    
    func startAnimation(duration: TimeInterval) {
        createCircleLayer()
        
        isRecording = true
        
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        // Set the animation duration appropriately
        animation.duration = duration
        animation.isRemovedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.delegate = self
        
        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 0
        animation.toValue = 1
        
        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        circleLayer!.strokeEnd = 1.0
        
        // Do the actual animation
        circleLayer!.add(animation, forKey: "animateCircle")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if (flag) {
            stopAnimation()
        }
    }
    
    func stopAnimation() {
        if (circleLayer != nil) {
            circleLayer!.removeAllAnimations()
        }
        
        removeCirclelayer()
        
        if (isRecording) {
            isRecording = false
            self.delegate?.finishedRecordingAnimation()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
