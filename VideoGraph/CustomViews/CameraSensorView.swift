//
//  CameraSensorView.swift
//  VideoGraph
//
//  Created by Admin on 16/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class CameraSensorView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // center point
        if let subLayers = self.layer.sublayers {
            for subLayer in subLayers {
                subLayer.removeFromSuperlayer()
            }
        }
        
        let centerCirclePath = UIBezierPath(arcCenter: CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0), radius: CGFloat(1), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = centerCirclePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.white.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.white.cgColor
        //you can change the line width
        shapeLayer.lineWidth = 0.0
        
        self.layer.addSublayer(shapeLayer)
        
        //sensor point
        let tempX = (rect.size.width / 2.0 - 2.0) * TheMotionManager.motionX
        let tempY = (rect.size.height / 2.0 - 2.0) * TheMotionManager.motionY

        let sensorCirclePath = UIBezierPath(arcCenter: CGPoint(x: rect.size.width / 2.0 + tempX, y: rect.size.height / 2.0 + tempY), radius: CGFloat(2), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayerForSensor = CAShapeLayer()
        shapeLayerForSensor.path = sensorCirclePath.cgPath
        
        //change the fill color
        shapeLayerForSensor.fillColor = UIColor.white.cgColor
        //you can change the stroke color
        shapeLayerForSensor.strokeColor = UIColor.white.cgColor
        //you can change the line width
        shapeLayerForSensor.lineWidth = 0.0
        
        self.layer.addSublayer(shapeLayerForSensor)
    }

}
