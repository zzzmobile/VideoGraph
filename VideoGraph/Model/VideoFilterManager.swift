//
//  VideoFilterManager.swift
//  VideoGraph
//
//  Created by Admin on 22/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AVFoundation

let TheVideoFilterManager = VideoFilterManager.sharedInstance

class VideoFilterManager: NSObject {
    static let sharedInstance = VideoFilterManager()
    
    let context = CIContext()
    let filterNames: [String] = ["None",
                                 "CISRGBToneCurveToLinear",
                                 "CILinearToSRGBToneCurve",
                                 "CIPhotoEffectInstant",
                                 "CIPhotoEffectProcess",
                                 "CIPhotoEffectTransfer",
                                 "CISepiaTone",
                                 "CIColorPosterize",
                                 "CISharpenLuminance",
                                 "CIColorClamp",
                                 "CIVignetteEffect",
                                 "CIPhotoEffectChrome",
                                 "CIPhotoEffectFade",
                                 "CILinearToSRGBToneCurve",
                                 "CIPhotoEffectTonal",
                                 "CIPhotoEffectNoir",
                                 "CIColorInvert",
                                 "CIPhotoEffectMono",
                                 "CIMaximumComponent",
                                 "CIMinimumComponent"]
    
    override init() {
        super.init()
    }
    
    func applyFilter(_ nFilterIdx: Int, _ image: UIImage) -> UIImage? {
        var cgImage: CGImage? = nil
        
        autoreleasepool {
            let ciImage = CIImage(cgImage: image.cgImage!)

            let effect = CIFilter(name: self.filterNames[nFilterIdx])
            effect!.setValue(ciImage, forKey: kCIInputImageKey)
            
            if (self.filterNames[nFilterIdx] == "CIColorPosterize") {
                effect!.setValue(3.0, forKey: "inputLevels")
            } else if (self.filterNames[nFilterIdx] == "CISharpenLuminance") {
                effect!.setValue(0.4, forKey: "inputSharpness")
            } else if (self.filterNames[nFilterIdx] == "CIColorClamp") {
                effect!.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
                effect!.setValue(CIVector(x: 0.8, y: 0.8, z: 0.8, w: 0.8), forKey: "inputMaxComponents")
            } else if (self.filterNames[nFilterIdx] == "CIVignetteEffect") {
                effect!.setValue(1.0, forKey: "inputRadius")
                effect!.setValue(0.4, forKey: "inputIntensity")
            }
            
            
            cgImage = self.context.createCGImage(effect!.outputImage!, from: ciImage.extent)
        }

        let filteredImage = UIImage(cgImage: cgImage!)
        cgImage = nil
        
        return filteredImage
    }

}
