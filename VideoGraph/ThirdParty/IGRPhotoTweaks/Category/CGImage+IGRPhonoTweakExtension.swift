//
//  CGImage+IGRPhonoTweakExtension.swift
//  Pods
//
//  Created by Vitalii Parovishnyk on 4/26/17.
//
//

import Foundation

extension CGImage {
    
    func transformedImage(_ transform: CGAffineTransform, sourceSize: CGSize, cropSize: CGSize, imageViewSize: CGSize) -> CGImage {
        var aspect: CGFloat = 0.0
        var outputSize: CGSize = .zero
        
        if (cropSize.width >= cropSize.height) {
            aspect = cropSize.height / cropSize.width
            outputSize = CGSize(width: Int(sourceSize.width), height: Int((sourceSize.width * aspect) / 4) * 4)
        } else {
            aspect = cropSize.width / cropSize.height
            outputSize = CGSize(width: Int((sourceSize.height * aspect) / 4) * 4, height: Int(sourceSize.height))
        }
        
        let bitmapBytesPerRow = 0
        
        let context = CGContext(data: nil,
                                width: Int(outputSize.width),
                                height: Int(outputSize.height),
                                bitsPerComponent: self.bitsPerComponent,
                                bytesPerRow: bitmapBytesPerRow,
                                space: self.colorSpace!,
                                bitmapInfo: self.bitmapInfo.rawValue)
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(CGRect(x: CGFloat.zero,
                             y: CGFloat.zero,
                             width: outputSize.width,
                             height: outputSize.height))
        
        var uiCoords = CGAffineTransform(scaleX: outputSize.width / cropSize.width,
                                         y: outputSize.height / cropSize.height)
        uiCoords = uiCoords.translatedBy(x: cropSize.width.half, y: cropSize.height.half)
        uiCoords = uiCoords.scaledBy(x: 1.0, y: -1.0)
        
        context?.concatenate(uiCoords)
        context?.concatenate(transform)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.draw(self, in: CGRect(x: (-imageViewSize.width.half),
                                              y: (-imageViewSize.height.half),
                                              width: imageViewSize.width,
                                              height: imageViewSize.height))
        
        let result = context!.makeImage()!
        
        return result
    }
    
}
