//
//  RulerSliderView.swift
//  VideoGraph
//
//  Created by Admin on 16/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

protocol RulerSliderViewDelegate {
    func rulerChanged(_ view: RulerSliderView, _ value: CGFloat, _ bTouchFinished: Bool)
    func rulerValueChangedForShow(_ view: RulerSliderView, _ value: CGFloat)
}

let RulerIndicatorWidth: CGFloat = 44.0
let RulerPadding: CGFloat = 50.0

class RulerSliderView: UIView {
    var delegate: RulerSliderViewDelegate? = nil
    var bEnabled: Bool = true
    
    private var minValue: CGFloat = 0.0
    private var maxValue: CGFloat = 0.0
    private var curValue: CGFloat = 0.0
    
    private var activeImage: UIImage? = nil
    private var unactiveImage: UIImage? = nil
    
    private var rulerImageView: UIImageView? = nil
    private var indicator: UIView? = nil
    
    private var realRatio: CGFloat = 0.0
    private var valuePerOneStep: CGFloat = 0.0
    
    var bContinousUpdate: Bool = false
    var nCounter: Int = 0
    
    required public convenience init(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
    }
    
    init(frame: CGRect, minValue: CGFloat, maxValue: CGFloat, curValue: CGFloat, activeImageName: String, unactiveImageName: String, continousUpdate: Bool = false) {
        super.init(frame: frame)
        
        self.bContinousUpdate = continousUpdate
        
        self.minValue = minValue
        self.maxValue = maxValue
        self.curValue = curValue
        
        self.activeImage = UIImage(named: activeImageName)
        self.unactiveImage = UIImage(named: unactiveImageName)
        
        let imageSize = self.activeImage!.size
        let imageViewSize = CGSize(width: self.frame.size.width - RulerPadding, height: self.frame.size.width * imageSize.height / imageSize.width)
        let bgImageView = UIImageView(frame: CGRect(origin: CGPoint(x: RulerPadding / 2, y: (self.frame.size.height - imageViewSize.height) / 2.0), size: imageViewSize))
        bgImageView.image = self.unactiveImage
        bgImageView.contentMode = .scaleAspectFit
        self.addSubview(bgImageView)

        self.realRatio = imageSize.width / bgImageView.frame.size.width
        
        self.rulerImageView = UIImageView(frame: bgImageView.frame)
        self.rulerImageView!.image = self.activeImage
        self.rulerImageView!.contentMode = .scaleAspectFit
        self.addSubview(self.rulerImageView!)

        valuePerOneStep = bgImageView.frame.width / CGFloat(maxValue - minValue)
        let indicatorPosX = valuePerOneStep * CGFloat(curValue - minValue)

        self.indicator = UIView(frame: CGRect(x: 0, y: 0, width: RulerIndicatorWidth, height: frame.height))
        self.indicator?.backgroundColor = UIColor.clear
        self.addSubview(self.indicator!)
        self.indicator?.center = CGPoint(x: RulerPadding / 2 + indicatorPosX, y: self.frame.size.height / 2.0)
        
        let subIndicator = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 8.0, height: self.rulerImageView!.frame.size.height + 4.0))
        subIndicator.backgroundColor = UIColor.white
        self.indicator?.addSubview(subIndicator)
        subIndicator.center = CGPoint(x: self.indicator!.frame.width / 2.0, y: self.indicator!.frame.height / 2.0)
        InterfaceManager.addShadowToView(subIndicator, UIColor.black, .zero, 4.0, 0.0)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureProc(_:)))
        self.indicator?.isUserInteractionEnabled = true
        self.indicator?.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureProc(_:)))
        self.addGestureRecognizer(tapGesture)
        
        showRuleImageView()
    }
    
    @objc func panGestureProc(_ sender: UIPanGestureRecognizer) {
        if (!self.bEnabled) {
            return
        }
        
        let translation = sender.translation(in: self)
        
        switch sender.state {
        case .began:
            nCounter = 0
            break
        case .changed:
            nCounter += 1
            if (nCounter >= 100) {
                nCounter = 0
            }
            
            let prevCenter = self.indicator!.center
            var newCenter = CGPoint(x: prevCenter.x + translation.x, y: prevCenter.y)
            
            if (newCenter.x <= RulerPadding / 2) {
                newCenter = CGPoint(x: RulerPadding / 2, y: prevCenter.y)
            } else if (newCenter.x >= self.frame.size.width - RulerPadding / 2) {
                newCenter = CGPoint(x: self.frame.size.width - RulerPadding / 2, y: prevCenter.y)
            }
            
            self.indicator?.center = newCenter
            showRuleImageView()
            
            if (self.bContinousUpdate && nCounter % 3 == 0) {
                rulerValueChanged()
            }
            
            sender.setTranslation(CGPoint.zero, in: self)

            break
        case .ended, .cancelled:
            rulerValueChanged(true)
            break
        default:
            break
        }
    }
    
    @objc func tapGestureProc(_ sender: UITapGestureRecognizer) {
        if (!self.bEnabled) {
            return
        }

        let location = sender.location(in: self)
        
        let prevCenter = self.indicator!.center
        var newCenter = CGPoint(x: location.x, y: prevCenter.y)
        if (newCenter.x <= RulerPadding / 2) {
            newCenter = CGPoint(x: RulerPadding / 2, y: prevCenter.y)
        } else if (newCenter.x >= self.frame.size.width - RulerPadding / 2) {
            newCenter = CGPoint(x: self.frame.size.width - RulerPadding / 2, y: prevCenter.y)
        }

        self.indicator?.center = newCenter
        showRuleImageView()
        
        rulerValueChanged(true)
    }
    
    func showRuleImageView(_ bNoNeedUpdate: Bool = true) {
        let imageSize = self.activeImage!.size
        
        let realIndicatorPosX = (self.indicator!.center.x - RulerPadding / 2) * realRatio
        
        //begin the image in context
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        let currentContext = UIGraphicsGetCurrentContext()
        self.activeImage!.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        
        currentContext?.setBlendMode(.clear)
        currentContext?.setFillColor(UIColor.clear.cgColor)
        
        let rectShape = CGRect(x: realIndicatorPosX, y: 0.0, width: imageSize.width - realIndicatorPosX, height: imageSize.height)
        currentContext?.addRect(rectShape)

        currentContext?.fillPath()
        
        let updatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.rulerImageView?.image = updatedImage
        
        if (bNoNeedUpdate) {
            let updatedValue = (self.indicator!.center.x - RulerPadding / 2) / valuePerOneStep + minValue
            self.delegate?.rulerValueChangedForShow(self, updatedValue)
        }
    }
    
    func rulerValueChanged(_ bPanFinished: Bool = false) {
        let updatedValue = (self.indicator!.center.x - RulerPadding / 2) / valuePerOneStep + minValue
        
        self.curValue = updatedValue
        
        if (self.delegate != nil) {
            self.delegate?.rulerChanged(self, updatedValue, bPanFinished)
        }
    }
    
    func setCurrentValue(_ value: CGFloat) {
        self.curValue = value
        
        let indicatorPosX = valuePerOneStep * CGFloat(curValue - minValue)
        self.indicator?.center = CGPoint(x: RulerPadding / 2 + indicatorPosX, y: self.frame.size.height / 2.0)

        showRuleImageView(false)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
