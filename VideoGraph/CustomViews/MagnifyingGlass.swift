//
//  MagnifyingGlass.swift
//  VideoGraph
//
//  Created by Admin on 16/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import QuartzCore

public let MagnifyingGlassDefaultRadius: CGFloat = 90.0
public let MagnifyingGlassDefaultOffset: CGFloat = -120.0
public let MagnifyingGlassDefaultScale: CGFloat = 3.0

public class MagnifyingGlass: UIView {
    public var viewToMagnify: UIView!
    public var touchPoint: CGPoint! {
        didSet {
            self.center = CGPoint(x: touchPoint.x + touchPointOffset.x, y: touchPoint.y + touchPointOffset.y)
        }
    }

    public var touchPointOffset: CGPoint!
    public var scale: CGFloat!
    public var scaleAtTouchPoint: Bool!
    public var targetImageView: UIImageView? = nil
    
    public func initViewToMagnify(viewToMagnify: UIView, touchPoint: CGPoint, touchPointOffset: CGPoint, scale: CGFloat, scaleAtTouchPoint: Bool) {
        self.viewToMagnify = viewToMagnify
        self.touchPoint = touchPoint
        self.touchPointOffset = touchPointOffset
        self.scale = scale
        self.scaleAtTouchPoint = scaleAtTouchPoint
    }

    required public convenience init(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
    }

    required public override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0
        self.layer.cornerRadius = frame.size.width / 2
        self.layer.masksToBounds = true
        
        self.touchPointOffset = CGPoint(x: 0, y: MagnifyingGlassDefaultOffset)
        self.scale = MagnifyingGlassDefaultScale
        self.viewToMagnify = nil
        self.scaleAtTouchPoint = true
        
        self.targetImageView = UIImageView(frame: self.bounds)
        self.targetImageView!.image = UIImage(named: "icon_magnify")
        self.targetImageView!.backgroundColor = UIColor.clear
        self.addSubview(self.targetImageView!)
    }

    private func setFrame(frame: CGRect) {
        super.frame = frame
        self.layer.cornerRadius = frame.size.width / 2
    }

    public override func draw(_ rect: CGRect) {
        self.targetImageView?.isHidden = true
        
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        context.scaleBy(x: self.scale, y: self.scale)
        context.translateBy(x: -self.touchPoint.x, y: -self.touchPoint.y + (self.scaleAtTouchPoint != nil ? 0 : self.bounds.size.height/2))
        self.viewToMagnify.layer.render(in: context)
        UIGraphicsEndImageContext()
        
        self.targetImageView?.isHidden = false
    }
}
