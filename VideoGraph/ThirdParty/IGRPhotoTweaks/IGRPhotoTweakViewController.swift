//
//  IGRPhotoTweakViewController.swift
//  IGRPhotoTweaks
//
//  Created by Vitalii Parovishnyk on 2/6/17.
//  Copyright © 2017 IGR Software. All rights reserved.
//

import UIKit


public protocol IGRPhotoTweakViewControllerDelegate : class {
    
    /**
     Called on image cropped.
     */
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage, entireTransform: CGAffineTransform, cropSize: CGSize, imageViewSize: CGSize, fliped: Bool, angle: CGFloat, rotateCnt: Int, contentViewFrame: CGRect, scrollViewFrame: CGRect, scrollViewContentOffset: CGPoint)
    /**
     Called on cropping image canceled
     */
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController)
}

open class IGRPhotoTweakViewController: UIViewController {
    
    //MARK: - Public VARs
    
    /*
     Image to process.
     */
    public var image: UIImage!
    
    /*
     The optional photo tweaks controller delegate.
     */
    public weak var delegate: IGRPhotoTweakViewControllerDelegate?
    
    //MARK: - Protected VARs
    
    /*
     Flag indicating whether the image cropped will be saved to photo library automatically. Defaults to YES.
     */
    internal var isAutoSaveToLibray: Bool = false
    
    //MARK: - Private VARs
    
    internal lazy var photoView: IGRPhotoTweakView! = { [unowned self] by in
        
        let photoView = IGRPhotoTweakView(frame: self.view.bounds,
                                          image: self.image,
                                          customizationDelegate: self)
        photoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(photoView)
        
        return photoView
        }(())
    
    // MARK: - Life Cicle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.clipsToBounds = true
        
        self.setupThemes()
        self.setupSubviews()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.photoView.applyDeviceRotation()
        })
    }
    
    fileprivate func setupSubviews() {
        self.view.sendSubviewToBack(self.photoView)
    }
    
    open func setupThemes() {
        IGRPhotoTweakView.appearance().backgroundColor = UIColor.photoTweakCanvasBackground()
        IGRPhotoContentView.appearance().backgroundColor = UIColor.clear
        IGRCropView.appearance().backgroundColor = UIColor.clear
        IGRCropGridLine.appearance().backgroundColor = UIColor.gridLine()
        IGRCropLine.appearance().backgroundColor = UIColor.cropLine()
        IGRCropCornerView.appearance().backgroundColor = UIColor.clear
        IGRCropCornerLine.appearance().backgroundColor = UIColor.cropLine()
        IGRCropMaskView.appearance().backgroundColor = UIColor.mask()
    }
    
    // MARK: - Public
    
    public func resetView() {
        self.photoView.resetView()
        self.stopChangeAngle()
    }

    public func setupPriorValues(_ transform: CGAffineTransform, _ cropSize: CGSize, _ fliped: Bool, _ angle: CGFloat, _ rotateCnt: Int, _ contentViewFrame: CGRect, _ scrollViewFrame: CGRect, _ scrollViewContentOffset: CGPoint) {
        self.photoView.setupPriorValues(cropSize, contentViewFrame, scrollViewFrame, scrollViewContentOffset, rotateCnt)

        self.changedAngle(value: angle)
        if (fliped) {
            self.flip()
        }
        
        self.stopChangeAngle()
    }
    
    public func dismissAction() {
        self.delegate?.photoTweaksControllerDidCancel(self)
    }
    
    public func cropAction() {
        var transform = CGAffineTransform.identity
        let radians = IGRRadianAngle.toRadians(90.0)
        
        // translate
        let translation: CGPoint = self.photoView.photoTranslation
        transform = transform.translatedBy(x: (self.photoView.fliped ? -1 * translation.x : translation.x), y: translation.y)
        
        // rotate
        transform = transform.rotated(by: self.photoView.angle - CGFloat(self.photoView.rotateCnt) * radians)
        
        // scale
        let t: CGAffineTransform = self.photoView.photoContentView.transform
        
        let xScale: CGFloat = sqrt(t.a * t.a + t.c * t.c)
        let yScale: CGFloat = sqrt(t.b * t.b + t.d * t.d)
        transform = transform.scaledBy(x: xScale, y: yScale)

        if let fixedImage = self.image.cgImageWithFixedOrientation() {
            let imageRef = fixedImage.transformedImage(transform,
                                                       sourceSize: self.image.size,
                                                       cropSize: self.photoView.cropView.frame.size,
                                                       imageViewSize: self.photoView.photoContentView.bounds.size)

            var image = UIImage(cgImage: imageRef)
            if (self.photoView.fliped) {
                image = image.flipImageLeftRight()!
            }
            
            if self.isAutoSaveToLibray {
                
                self.saveToLibrary(image: image)
            }
            
            self.delegate?.photoTweaksController(self, didFinishWithCroppedImage: image, entireTransform: transform, cropSize: self.photoView.cropView.frame.size, imageViewSize: self.photoView.photoContentView.bounds.size, fliped: self.photoView.fliped, angle: self.photoView.angle, rotateCnt: self.photoView.rotateCnt, contentViewFrame: self.photoView.photoContentView.frame, scrollViewFrame: self.photoView.scrollView.frame, scrollViewContentOffset: self.photoView.scrollView.contentOffset)
        }
    }
    
    //MARK: - Customization
    
    open func customBorderColor() -> UIColor {
        return UIColor.cropLine()
    }
    
    open func customBorderWidth() -> CGFloat {
        return 1.0
    }
    
    open func customCornerBorderWidth() -> CGFloat {
        return kCropViewCornerWidth
    }
    
    open func customCornerBorderLength() -> CGFloat {
        return kCropViewCornerLength
    }
    
    open func customIsHighlightMask() -> Bool {
        return true
    }
    
    open func customHighlightMaskAlphaValue() -> CGFloat {
        return 0.3
    }
    
    open func customCanvasHeaderHeigth() -> CGFloat {
        return kCanvasHeaderHeigth
    }
}
