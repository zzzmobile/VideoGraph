//
//  UIImage+IGRPhonoTweakExtension.swift
//  Pods
//
//  Created by Vitalii Parovishnyk on 4/26/17.
//
//

import UIKit

extension UIImage {
    
    func flipImageLeftRight() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: self.size.width, y: self.size.height)
        context.scaleBy(x: -1, y: -1)
        
        context.draw(self.cgImage!, in: CGRect(origin:CGPoint.zero, size: self.size))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func cgImageWithFixedOrientation() -> CGImage? {
        
        guard let cgImage = self.cgImage, let colorSpace = cgImage.colorSpace else {
            return nil
        }
        
        if self.imageOrientation == UIImage.Orientation.up {
            return self.cgImage
        }
        
        let width  = self.size.width
        let height = self.size.height
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: CGFloat.pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.rotated(by: 0.5 * CGFloat.pi)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: height)
            transform = transform.rotated(by: -0.5 * CGFloat.pi)
            
        case .up, .upMirrored:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break
        }
        
        guard let context = CGContext(
            data: nil,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)
            ) else {
                return nil
        }
        
        context.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
            
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let newCGImg = context.makeImage() else {
            return nil
        }
        
        return newCGImg
    }
}
