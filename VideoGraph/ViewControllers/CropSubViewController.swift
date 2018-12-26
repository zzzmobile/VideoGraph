//
//  CropSubViewController.swift
//  VideoGraph
//
//  Created by Admin on 17/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class CropSubViewController: IGRPhotoTweakViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge()
        self.view.backgroundColor = Constants.Colors.GrayBG
        
        let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            self.doReset()
            if (TheVideoEditor.cropSettings.bUpdated) {
                DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                    self.setupPriorValues(TheVideoEditor.cropSettings.entireTransform, TheVideoEditor.cropSettings.cropSize, TheVideoEditor.cropSettings.fliped, TheVideoEditor.cropSettings.angle, TheVideoEditor.cropSettings.rotateCnt, TheVideoEditor.cropSettings.contentViewFrame, TheVideoEditor.cropSettings.scrollViewFrame, TheVideoEditor.cropSettings.scrollViewContentOffset)
                })
            }
        })
    }
 
    func doLockRatio(_ bLocked: Bool) {
        self.lockAspectRatio(bLocked)
    }
    
    func doReset() {
        self.resetView()
    }
    
    func doCrop() {
        self.cropAction()
    }
    
    func doRotate(_ degrees: CGFloat) {
        let radians = IGRRadianAngle.toRadians(degrees)
        
        self.changedAngle(value: radians)
        self.stopChangeAngle()
    }

    func doRotateBy90() {
        self.changedAngleBy90()
        self.stopChangeAngle()
    }

    func doFlip() {
        self.flip()
    }

    func doSetupRatio(_ bOriginal: Bool = true, _ strRatio: String = "") {
        if (bOriginal) {
            self.resetAspectRect()
        } else {
            self.setCropAspectRect(aspect: strRatio)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Theme Setup
    override open func setupThemes() {
        IGRCropLine.appearance().backgroundColor = UIColor.white
        IGRCropGridLine.appearance().backgroundColor = UIColor.white
        IGRCropCornerLine.appearance().backgroundColor = UIColor.white
        IGRCropMaskView.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        IGRPhotoContentView.appearance().backgroundColor = UIColor.gray
        IGRPhotoTweakView.appearance().backgroundColor = UIColor.black
        
        /*
         self.photoView.isHighlightMask = true
         self.photoView.highlightMaskAlphaValue = 0.2
         self.maxRotationAngle = CGFloat(M_PI * 2.0)
         */
    }
    
    override open func customBorderColor() -> UIColor {
        return UIColor.white
    }
    
    override open func customBorderWidth() -> CGFloat {
        return 2.0
    }
    
    override open func customCornerBorderWidth() -> CGFloat {
        return 4.0
    }
    
    override open func customCornerBorderLength() -> CGFloat {
        return 12.0
    }
    
    override open func customCanvasHeaderHeigth() -> CGFloat {
        var height: CGFloat = 0.0
        
        if (TheInterfaceManager.checkiPhoneX()) {
            height = 64.0 + 44.0 + 20.0
        } else {
            height = 64.0 + 20.0 + 20.0
        }
        
        return height
    }
}
