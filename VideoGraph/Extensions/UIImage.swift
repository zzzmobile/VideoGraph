//
//  UIImage.swift
//  VideoGraph
//
//  Created by Admin on 13/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AssetsLibrary
import ImageIO
import AVFoundation

extension UIImage {
    func cropImageWithRect(_ newSize: CGSize) -> UIImage {
        let size = self.size
        
        let origin = CGPoint(x: -1 * (size.width - newSize.width) / 2.0, y: -1 * (size.height - newSize.height) / 2.0)

        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(at: origin)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        if (image != nil)
        {
            return image!
        }
        
        return UIImage()
    }
    
    func cropImageWithRectAndScale(_ newSize: CGSize, _ scale: CGFloat = 1.0) -> UIImage {
        let size = self.size
        
        let origin = CGPoint(x: -1 * (size.width - newSize.width) / 2.0, y: -1 * (size.height - newSize.height) / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        self.draw(at: origin)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        if (image != nil)
        {
            return image!
        }
        
        return UIImage()
    }
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    var cvPixelBuffer: CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil
        let options: [NSObject: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: false,
            kCVPixelBufferCGBitmapContextCompatibilityKey: false,
            ]
        _ = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, options as CFDictionary, &pixelBuffer)
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue)
        context?.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
    
    var cmSampleBuffer: CMSampleBuffer {
        let pixelBuffer = cvPixelBuffer
        var newSampleBuffer: CMSampleBuffer? = nil
        var timimgInfo: CMSampleTimingInfo = CMSampleTimingInfo.invalid
        var videoInfo: CMVideoFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: pixelBuffer!, formatDescriptionOut: &videoInfo)
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer!, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: videoInfo!, sampleTiming: &timimgInfo, sampleBufferOut: &newSampleBuffer)
        return newSampleBuffer!
    }
    
    func getPixelColor(_ point: CGPoint) -> UIColor? {
        if (point.x < 0 || point.x >= size.width || point.y < 0 || point.y >= size.height) {
            return nil
        }
        
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let width = Int(size.width)
        let height = Int(size.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let colorContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        colorContext!.clear(imageRect)
        colorContext!.draw(cgImage, in: imageRect)
        
        let data = colorContext!.data
        let dataType = data!.assumingMemoryBound(to: UInt8.self)
        
        let offset = 4 * (width * Int(point.y)) + Int(point.x) * 4
        let alphaComponent = CGFloat(dataType[offset + 3])/255.0
        let redComponent = CGFloat(dataType[offset + 2])/255.0
        let greenComponent = CGFloat(dataType[offset + 1])/255.0
        let blueComponent = CGFloat(dataType[offset])/255.0
        
        return UIColor(red: redComponent, green: greenComponent, blue: blueComponent, alpha: alphaComponent)
    }
}
