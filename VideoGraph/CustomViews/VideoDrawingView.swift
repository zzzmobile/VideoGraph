//
//  VideoDrawingView.swift
//  VideoGraph
//
//  Created by Admin on 21/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class VideoDrawingView: UIView, UIGestureRecognizerDelegate {
    var workingCanvasView: UIView? = nil
    
    var bTouchMoved: Bool = false
    var ptTouchStart: CGPoint = .zero
    var ptTouchMoveStart: CGPoint = .zero
    
    var drawingImageView: UIImageView? = nil
    var maskImageView: UIImageView? = nil
    
    var maskImage: UIImage? = nil
    
    private var context: CIContext = CIContext(options: [CIContextOption.workingColorSpace : NSNull()])

    //variables for magnify
    var magnifyingGlassShowDelay: TimeInterval = 0.1
    var touchTimer: Timer!
    var magnifyingGlass: MagnifyingGlass? = nil

    deinit {
        NotificationCenter.default.removeObserver(self)
        
        if (drawingImageView != nil) {
            self.drawingImageView!.layer.removeAllAnimations()
        }
    }

    func hideAllSubViewsForOriginalVideo(_ isHidden: Bool) {
        if (isHidden) {
            self.drawingImageView?.isHidden = true
            self.maskImageView?.isHidden = true
        } else {
            self.drawingImageView?.isHidden = false
            self.maskImageView?.isHidden = (TheVideoEditor.editSettings.bShowMaskAlways ? false : true)
        }
    }
    
    func showOverlayThumbnail(_ thumbSize: CGSize) {
        self.maskImage = nil
        
        NotificationCenter.default.removeObserver(self)

        NotificationCenter.default.addObserver(self, selector: #selector(applyFilter), name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(croppedVideo), name: NSNotification.Name(rawValue: Constants.NotificationName.CroppedVideo), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateMaskFeature), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskFeature), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMaskVisible), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskVisible), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMaskOpacity), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskOpacity), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMaskColor), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskColor), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(didUndoProcess), name: NSNotification.Name(rawValue: Constants.NotificationName.didUndoProcess), object: nil)

        self.drawingImageView = UIImageView(frame: .zero)
        self.drawingImageView?.contentMode = .scaleAspectFill
        self.drawingImageView?.clipsToBounds = true
        //self.drawingImageView?.isHidden = true
        self.addSubview(self.drawingImageView!)
        
        let widthRatio = thumbSize.width / self.frame.width
        let heightRatio = thumbSize.height / self.frame.height
        
        var imageViewSize = CGSize.zero
        if (thumbSize.height / widthRatio > self.frame.height) {
            imageViewSize = CGSize(width: thumbSize.width / heightRatio, height: thumbSize.height / heightRatio)
        } else {
            imageViewSize = CGSize(width: thumbSize.width / widthRatio, height: thumbSize.height / widthRatio)
        }
        
        self.drawingImageView?.frame = CGRect(origin: .zero, size: imageViewSize)
        self.drawingImageView?.center = CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0)
        
        self.maskImageView = UIImageView(frame: self.drawingImageView!.frame)
        self.maskImageView?.backgroundColor = UIColor.clear
        self.addSubview(self.maskImageView!)
        showMaskImage(thumbSize)
        
        setAlphaAndShow()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapProc(_:)))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
    }

    @objc func didUndoProcess() {
        let thumbSize = TheImageProcesser.getCorrectStillImage().size
        
        let widthRatio = thumbSize.width / self.frame.width
        let heightRatio = thumbSize.height / self.frame.height
        
        var imageViewSize = CGSize.zero
        if (thumbSize.height / widthRatio > self.frame.height) {
            imageViewSize = CGSize(width: thumbSize.width / heightRatio, height: thumbSize.height / heightRatio)
        } else {
            imageViewSize = CGSize(width: thumbSize.width / widthRatio, height: thumbSize.height / widthRatio)
        }
        
        self.drawingImageView?.frame = CGRect(origin: .zero, size: imageViewSize)
        self.drawingImageView?.center = CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0)
        self.maskImageView?.frame = self.drawingImageView!.frame

        self.drawingImageView?.image = TheImageProcesser.getCorrectStillImage()
        
        self.maskImage = TheVideoEditor.originalMaskImageForUndo
        self.maskImageView?.image = TheVideoEditor.currentMaskImageForUndo
        
        TheImageProcesser.getRealImageFromMask(self.drawingImageView, self.maskImageView)

        setAlphaAndShow()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        print("got touch")
        return true
    }
    
    func showStillImage() {
        //self.drawingImageView?.image = TheVideoEditor.stillImage
        TheImageProcesser.getRealImageFromMask(self.drawingImageView, self.maskImageView)
    }

    func showStillMaskImageForProject() {
        let thumbSize = TheImageProcesser.getCorrectStillImage().size
        
        let widthRatio = thumbSize.width / self.frame.width
        let heightRatio = thumbSize.height / self.frame.height
        
        var imageViewSize = CGSize.zero
        if (thumbSize.height / widthRatio > self.frame.height) {
            imageViewSize = CGSize(width: thumbSize.width / heightRatio, height: thumbSize.height / heightRatio)
        } else {
            imageViewSize = CGSize(width: thumbSize.width / widthRatio, height: thumbSize.height / widthRatio)
        }
        
        self.drawingImageView?.frame = CGRect(origin: .zero, size: imageViewSize)
        self.drawingImageView?.center = CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0)
        self.maskImageView?.frame = self.drawingImageView!.frame
        
        self.drawingImageView?.image = TheImageProcesser.getCorrectStillImage()
        
        self.maskImage = self.maskImageView!.image
        self.maskImageView?.image = TheVideoEditor.currentMaskImageForUndo
        
        TheImageProcesser.getRealImageFromMask(self.drawingImageView, self.maskImageView)
        
        setAlphaAndShow()
    }
    
    func showMaskImage(_ imageSize: CGSize) {
        self.maskImageView?.image = TheImageProcesser.makeOverlayImage(imageSize)
    }

    @objc func setAlphaAndShow() {
        self.drawingImageView?.alpha = TheVideoEditor.editSettings.maskOpacity / 100.0
        
        self.maskImageView?.alpha = TheVideoEditor.editSettings.maskOpacity / 100.0
        self.maskImageView?.isHidden = (TheVideoEditor.editSettings.bShowMaskAlways ? false : true)
    }
    
    @objc func updateMaskFeature() {
        //feature for mask all, unmask all
        if (TheVideoEditor.editSettings.bMaskAll) {
            self.maskImageView?.image = TheImageProcesser.makeEmptyOverlayImage(self.maskImageView!.image!.size)
            TheImageProcesser.getRealImageFromMask(self.drawingImageView, self.maskImageView)
        } else {
            self.maskImageView?.image = TheImageProcesser.makeOverlayImage(self.maskImageView!.image!.size)
            TheImageProcesser.getRealImageFromMask(self.drawingImageView, self.maskImageView)
        }
    }
    
    @objc func updateMaskOpacity() {
        self.setAlphaAndShow()
    }

    @objc func updateMaskColor() {
        TheImageProcesser.updateOverlayImage(self.maskImageView)
    }

    @objc func updateMaskVisible() {
        self.setAlphaAndShow()
    }

    @objc func croppedVideo() {
        let drawingImage = TheImageProcesser.getCorrectStillImage()
        self.drawingImageView?.image = drawingImage
        let thumbSize = drawingImage.size
        
        let widthRatio = thumbSize.width / self.frame.width
        let heightRatio = thumbSize.height / self.frame.height
        
        var imageViewSize = CGSize.zero
        if (thumbSize.height / widthRatio > self.frame.height) {
            imageViewSize = CGSize(width: thumbSize.width / heightRatio, height: thumbSize.height / heightRatio)
        } else {
            imageViewSize = CGSize(width: thumbSize.width / widthRatio, height: thumbSize.height / widthRatio)
        }
        
        self.drawingImageView?.frame = CGRect(origin: .zero, size: imageViewSize)
        self.drawingImageView?.center = CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0)
        
        self.maskImageView?.frame = self.drawingImageView!.frame
        
        //update mask
        if (!TheVideoEditor.priorCropSettings.bUpdated) {
            self.maskImage = self.maskImageView!.image
            
            self.maskImageView?.image = TheImageProcesser.cropMaskImage(self.maskImage!)
            TheImageProcesser.getRealImageFromMask(self.drawingImageView, self.maskImageView)
        } else {
            //merge mask images before and after crop
            if (self.maskImage == nil) {
                self.maskImage = TheImageProcesser.makeOverlayImage(TheVideoEditor.initialStillImageSize)
            }
            
            let restoredMaskImage = TheImageProcesser.makeFullMaskImageWithCrop(self.maskImage!, self.maskImageView!.image!)
            self.maskImage = restoredMaskImage
            
            self.maskImageView?.image = TheImageProcesser.cropMaskImage(restoredMaskImage!)
            TheImageProcesser.getRealImageFromMask(self.drawingImageView, self.maskImageView)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @objc func tapProc(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        
        print("tapped")
        
        if (self.maskImageView!.frame.contains(location)) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.ShowHideTopBarsInEditViewAsAlways), object: nil, userInfo: nil)
        }
    }
    
    func showHideDrawingViewForExport(_ bShow: Bool) {
        if (bShow) {
            self.maskImageView?.isHidden = (TheVideoEditor.editSettings.bShowMaskAlways ? false : true)
        } else {
            self.maskImageView?.isHidden = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)

        ptTouchStart = location
        
        /*
        if (self.maskImageView!.frame.contains(location)) {
            self.maskImageView?.isHidden = false
            
            bTouchMoved = false
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.ShowHideTopBarsInEditViewAsAlways), object: nil, userInfo: nil)
            
            let realPos = self.convert(location, to: self.maskImageView!)
            
            if (TheImageProcesser.bEraserMode) {
                TheImageProcesser.eraseMaskImage(self.maskImageView!, realPos)
            } else {
                TheImageProcesser.restoreMaskImage(self.maskImageView!, realPos)
            }
            
            TheImageProcesser.getRealImageFromMask(self.drawingImageView, self.maskImageView)
        }
        */
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch moved")
        
        let touch = touches.first!
        let location = touch.location(in: self)

        if (location == ptTouchStart) {
            return
        }

        if (self.maskImageView!.frame.contains(location)) {
            self.maskImageView?.isHidden = false
            
            let realPos = self.convert(location, to: self.maskImageView!)
            if (!bTouchMoved) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.HideTopBarsInEditViewJustOnce), object: nil, userInfo: nil)
                
                self.removeMagnifyingGlass()
            }
            
            if (bTouchMoved) {
                self.updateMagnifyingGlassAtPoint(location)

                if (TheImageProcesser.bEraserMode) {
                    TheImageProcesser.eraseMaskImage(self.maskImageView!, ptTouchStart, realPos)
                } else {
                    TheImageProcesser.restoreMaskImage(self.maskImageView!, ptTouchStart, realPos)
                }
                
                TheImageProcesser.getRealImageFromMask(self.drawingImageView, self.maskImageView)
            } else {
                self.touchTimer = Timer.scheduledTimer(timeInterval: magnifyingGlassShowDelay, target: self, selector: #selector(addMagnifyingGlassTimer(_:)), userInfo: NSValue(cgPoint: location), repeats: false)
            }
            
            bTouchMoved = true
            ptTouchStart = realPos
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch ended")
        
        if (bTouchMoved) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.ShowTopBarsInEditViewJustOnce), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        }
        
        let delayTime = DispatchTime.now() + Double(Int64(magnifyingGlassShowDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            self.removeMagnifyingGlass()
        })
        
        bTouchMoved = false
        self.maskImageView?.isHidden = (TheVideoEditor.editSettings.bShowMaskAlways ? false : true)

        /*
        let touch = touches.first!
        let location = touch.location(in: self)

        self.maskImageView?.isHidden = (TheVideoEditor.editSettings.bShowMaskAlways ? false : true)
        
        if (self.maskImageView!.frame.contains(location)) {
            self.maskImageView?.isHidden = (TheVideoEditor.editSettings.bShowMaskAlways ? false : true)

            if (bTouchMoved) {
                bTouchMoved = true
                
                let realPos = self.convert(location, to: self.maskImageView!)
                
                if (TheImageProcesser.bEraserMode) {
                    TheImageProcesser.eraseMaskImage(self.maskImageView!, realPos)
                } else {
                    TheImageProcesser.restoreMaskImage(self.maskImageView!, realPos)
                }
                
                TheImageProcesser.getRealImageFromMask(self.drawingImageView, self.maskImageView)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.ShowTopBarsInEditViewJustOnce), object: nil, userInfo: nil)
            }
        }
        */
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch cancelled")

        bTouchMoved = false
        self.maskImageView?.isHidden = (TheVideoEditor.editSettings.bShowMaskAlways ? false : true)
        
        let delayTime = DispatchTime.now() + Double(Int64(magnifyingGlassShowDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            self.removeMagnifyingGlass()
        })
    }
    
    // MARK: - Magnify Control functions
    private func addMagnifyingGlassAtPoint(_ point: CGPoint) {
        if (self.magnifyingGlass != nil) {
            self.magnifyingGlass?.removeFromSuperview()
            self.magnifyingGlass = nil
        }
        
        self.magnifyingGlass = MagnifyingGlass(frame: CGRect(x: 0.0, y: 0.0, width: 2.0 * MagnifyingGlassDefaultRadius, height: 2.0 * MagnifyingGlassDefaultRadius))
        self.magnifyingGlass!.viewToMagnify = self.workingCanvasView
        self.magnifyingGlass!.touchPoint = point
        
        self.addSubview(self.magnifyingGlass!)
        
        self.magnifyingGlass!.setNeedsDisplay()
    }
    
    private func removeMagnifyingGlass() {
        if (self.magnifyingGlass != nil) {
            self.magnifyingGlass!.removeFromSuperview()
        }
    }
    
    private func updateMagnifyingGlassAtPoint(_ point: CGPoint) {
        if (self.magnifyingGlass != nil) {
            self.magnifyingGlass!.touchPoint = point
            self.magnifyingGlass!.setNeedsDisplay()
        }
    }
    
    @objc public func addMagnifyingGlassTimer(_ timer: Timer) {
        let value: AnyObject? = timer.userInfo as AnyObject?
        if let point = value?.cgPointValue {
            self.addMagnifyingGlassAtPoint(point)
        }
    }
    
    @objc func applyFilter() {
        autoreleasepool {
            guard let image = TheImageProcesser.makeDrawingImageFromMask(self.maskImageView) else {
                return
            }
            
            let baseImg = CIImage(cgImage: image.cgImage!)
            var processCIImage: CIImage = baseImg.clampedToExtent().cropped(to: baseImg.extent)
            
            //video filter
            if (TheVideoEditor.editSettings.filterIdx > 0) {
                if (TheVideoFilterManager.filterNames[TheVideoEditor.editSettings.filterIdx] == "CIColorPosterize") {
                    processCIImage = processCIImage.applyingFilter(TheVideoFilterManager.filterNames[TheVideoEditor.editSettings.filterIdx], parameters: ["inputLevels" : 3.0])
                } else if (TheVideoFilterManager.filterNames[TheVideoEditor.editSettings.filterIdx] == "CISharpenLuminance") {
                    processCIImage = processCIImage.applyingFilter(TheVideoFilterManager.filterNames[TheVideoEditor.editSettings.filterIdx], parameters: ["inputSharpness" : 0.4])
                } else if (TheVideoFilterManager.filterNames[TheVideoEditor.editSettings.filterIdx] == "CIColorClamp") {
                    processCIImage = processCIImage.applyingFilter(TheVideoFilterManager.filterNames[TheVideoEditor.editSettings.filterIdx], parameters: ["inputMinComponents" : CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2),
                                                                                                                                                          "inputMaxComponents": CIVector(x: 0.8, y: 0.8, z: 0.8, w: 0.8)])
                } else if (TheVideoFilterManager.filterNames[TheVideoEditor.editSettings.filterIdx] == "CIVignetteEffect") {
                    processCIImage = processCIImage.applyingFilter(TheVideoFilterManager.filterNames[TheVideoEditor.editSettings.filterIdx], parameters: ["inputRadius" : 1.0,
                                                                                                                                                          "inputIntensity": 0.4])
                } else {
                    processCIImage = processCIImage.applyingFilter(TheVideoFilterManager.filterNames[TheVideoEditor.editSettings.filterIdx])
                }
            }
            
            //video tune
            processCIImage = processCIImage.applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: TheVideoEditor.editSettings.saturation,
                                                                                           kCIInputBrightnessKey: TheVideoEditor.editSettings.brightness,
                                                                                           kCIInputContrastKey: TheVideoEditor.editSettings.contrast])
            
            processCIImage = processCIImage.applyingFilter("CIVignette", parameters: [kCIInputIntensityKey: TheVideoEditor.editSettings.intensity,
                                                                                      kCIInputRadiusKey: TheVideoEditor.editSettings.radius])
            
            processCIImage = processCIImage.applyingFilter("CIExposureAdjust", parameters: [kCIInputEVKey: TheVideoEditor.editSettings.exposure])
            
            if (TheVideoEditor.bChangedTemperature) {
                let tempColor = TheGlobalPoolManager.getTempColorBetweenTwoColors((TheVideoEditor.editSettings.temperature + 10.0) / 20.0)
                processCIImage = processCIImage.applyingFilter("CIWhitePointAdjust", parameters: [kCIInputColorKey: CIColor(color: tempColor)])
            }
            
            if (TheVideoEditor.bChangedTint) {
                let tintColor = TheGlobalPoolManager.getTintColorBetweenTwoColors((TheVideoEditor.editSettings.tint + 10.0) / 20.0)
                processCIImage = processCIImage.applyingFilter("CIWhitePointAdjust", parameters: [kCIInputColorKey: CIColor(color: tintColor)])
            }
            
            //tone curve part
            if (TheVideoEditor.bChangedToneCurve) {
                var nGamma: CGFloat = 0.0
                
                var nR: CGFloat = 0.0
                var nG: CGFloat = 0.0
                var nB: CGFloat = 0.0
                
                var nBlacks: CGFloat = 0.0
                var nWhites: CGFloat = 0.0
                var nShadows: CGFloat = 0.0
                var nHighlights: CGFloat = 0.0
                
                var nBlackFilterValue: CGFloat = 0.0
                var nWhiteFilterValue: CGFloat = 0.0
                var nShadowFilterValue: CGFloat = 0.0
                var nHighlightFilterValue: CGFloat = 0.0
                
                switch TheVideoEditor.editSettings.toneCurveMode {
                case .R:
                    nGamma = 0.75
                    nR = 1.0
                    nBlacks = TheVideoEditor.editSettings.blacks_r
                    nWhites = TheVideoEditor.editSettings.whites_r
                    nShadows = TheVideoEditor.editSettings.shadows_r
                    nHighlights = TheVideoEditor.editSettings.highlights_r
                    break
                case .G:
                    nGamma = 0.5
                    nG = 1.0
                    nBlacks = TheVideoEditor.editSettings.blacks_g
                    nWhites = TheVideoEditor.editSettings.whites_g
                    nShadows = TheVideoEditor.editSettings.shadows_g
                    nHighlights = TheVideoEditor.editSettings.highlights_g
                    break
                case .B:
                    nGamma = 0.25
                    nB = 1.0
                    nBlacks = TheVideoEditor.editSettings.blacks_b
                    nWhites = TheVideoEditor.editSettings.whites_b
                    nShadows = TheVideoEditor.editSettings.shadows_b
                    nHighlights = TheVideoEditor.editSettings.highlights_b
                    break
                case .RGB:
                    nGamma = 1.0
                    nR = 1.0
                    nG = 1.0
                    nB = 1.0
                    nBlacks = TheVideoEditor.editSettings.blacks
                    nWhites = TheVideoEditor.editSettings.whites
                    nShadows = TheVideoEditor.editSettings.shadows
                    nHighlights = TheVideoEditor.editSettings.highlights
                    break
                }
                
                /*
                 processCIImage = processCIImage.applyingFilter("CIColorMatrix", parameters: ["inputRVector": CIVector(x: nR, y: 0.0, z: 0.0, w: 0.0),
                 "inputGVector": CIVector(x: 0.0, y: nG, z: 0.0, w: 0.0),
                 "inputBVector": CIVector(x: 0.0, y: 0.0, z: nB, w: 0.0),
                 "inputAVector": CIVector(x: 0.0, y: 0.0, z: 0.0, w: 1.0)])
                 */
                processCIImage = processCIImage.applyingFilter("CIGammaAdjust", parameters: ["inputPower": nGamma])
                
                //make blacks and whites
                let ValueStep: CGFloat = 10.0
                
                if (nWhites > 0) {
                    nWhiteFilterValue = (180.0 - nWhites * ValueStep) / 255.0
                } else if (nBlacks < 0) {
                    nWhiteFilterValue = (180.0 + nWhites * ValueStep) / 255.0
                } else {
                    nWhiteFilterValue = 1.0
                }
                
                if (nBlacks < 0) {
                    nBlackFilterValue = (40.0 - (-1.0) * nBlacks * ValueStep) / 255.0
                } else if (nBlacks > 0) {
                    nBlackFilterValue = (40.0 - nBlacks * ValueStep) / 255.0
                } else {
                    nBlackFilterValue = 0.0
                }
                
                processCIImage = processCIImage.applyingFilter("CIColorClamp", parameters: ["inputMinComponents": CIVector(x: nBlackFilterValue, y: nBlackFilterValue, z: nBlackFilterValue, w: 0.0),
                                                                                            "inputMaxComponents": CIVector(x: nWhiteFilterValue, y: nWhiteFilterValue, z: nWhiteFilterValue, w: 1.0)])
                
                if (nHighlights > 0) {
                    nHighlightFilterValue = (128.0 - nHighlights * ValueStep) / 255.0
                } else if (nBlacks < 0) {
                    nHighlightFilterValue = (128.0 + nHighlights * ValueStep) / 255.0
                } else {
                    nHighlightFilterValue = 1.0
                }
                
                if (nShadows < 0) {
                    nShadowFilterValue = (128.0 - (-1.0) * nShadows * ValueStep) / 255.0
                } else if (nBlacks > 0) {
                    nShadowFilterValue = (128.0 + nShadows * ValueStep) / 255.0
                } else {
                    nShadowFilterValue = 0.0
                }
                
                processCIImage = processCIImage.applyingFilter("CIHighlightShadowAdjust", parameters: ["inputHighlightAmount": nHighlightFilterValue,
                                                                                                       "inputShadowAmount": nShadowFilterValue])
            }
            
            guard let cgImg = self.context.createCGImage(processCIImage, from: processCIImage.extent) else {
                print("failed to make filter image")
                
                return
            }
            
            self.drawingImageView!.image = UIImage(cgImage: cgImg)
        }
    }
}
