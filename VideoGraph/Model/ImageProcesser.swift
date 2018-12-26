//
//  ImageProcesser.swift
//  VideoGraph
//
//  Created by Admin on 22/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

let TheImageProcesser = ImageProcesser.sharedInstance

class ImageProcesser: NSObject {
    static let sharedInstance = ImageProcesser()
    
    var bEraserMode: Bool = true

    override init() {
        super.init()
    }
    
    func changeColorSpace(_ image: UIImage) -> UIImage {
        let inputCGImage = image.cgImage!
        
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        context!.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        let updatedCGImage = context!.makeImage()!
        let copyImage = UIImage(cgImage: updatedCGImage, scale: image.scale, orientation: image.imageOrientation)
        
        return copyImage
    }
    
    func getCorrectStillImage() -> UIImage {
        if (!TheVideoEditor.cropSettings.bUpdated) {
            return TheVideoEditor.stillImage!
        } else {
            let cgImg = TheVideoEditor.cropImageWithCropSettings(TheVideoEditor.stillImage!.cgImage!)!
            return UIImage(cgImage: cgImg)
        }
    }
    
    func cropMaskImage(_ maskImage: UIImage) -> UIImage? {
        var croppedCGImage = maskImage.cgImage!
        
        if (TheVideoEditor.cropSettings.bUpdated) {
            croppedCGImage = croppedCGImage.transformedImage(TheVideoEditor.cropSettings.entireTransform,
                                                           sourceSize: TheVideoEditor.stillImage!.size,
                                                           cropSize: TheVideoEditor.cropSettings.cropSize,
                                                           imageViewSize: TheVideoEditor.cropSettings.imageViewSize)
            
        }

        let croppedImage = UIImage(cgImage: croppedCGImage)

        return croppedImage
    }
    
    func makeFullMaskImageWithCrop(_ maskImage: UIImage, _ currentMaskImage: UIImage) -> UIImage? {
        let imageSize = maskImage.size
        let currentMaskImageSize = currentMaskImage.size
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        let currentContext = UIGraphicsGetCurrentContext()
        
        maskImage.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        
        //apply transforms
        let transform = TheVideoEditor.priorCropSettings.entireTransform
        let scrollViewOffset = TheVideoEditor.priorCropSettings.scrollViewContentOffset
        let angle = atan2(transform.b, transform.a)
        
        let scaleX = sqrt(Double(transform.a * transform.a + transform.c * transform.c))
        let scaleY = sqrt(Double(transform.b * transform.b + transform.d * transform.d))
        
        let drawRect = CGRect(x: 0.0, y: 0.0, width: currentMaskImageSize.width / CGFloat(scaleX), height: currentMaskImageSize.height / CGFloat(scaleY))
        let drawRectCenter = CGPoint(x: drawRect.midX, y: drawRect.midY)
        
        let updatedDrawRect = drawRect.applying(CGAffineTransform(rotationAngle: -1 * angle))
        let temp_translationX = (updatedDrawRect.size.width - drawRect.size.width) / 2.0
        let temp_translationY = (updatedDrawRect.size.height - drawRect.size.height) / 2.0
        
        let translation_scaleX = imageSize.width / TheVideoEditor.priorCropSettings.contentViewFrame.width
        let translation_scaleY = imageSize.height / TheVideoEditor.priorCropSettings.contentViewFrame.height
        
        currentContext?.translateBy(x: scrollViewOffset.x * translation_scaleX + drawRectCenter.x + temp_translationX, y: scrollViewOffset.y * translation_scaleY + drawRectCenter.y + temp_translationY)
        currentContext?.saveGState()
        
        currentContext?.rotate(by: -1 * angle)
        
        currentMaskImage.draw(in: CGRect(origin: CGPoint(x: -drawRect.size.width / 2.0, y: -drawRect.size.height / 2.0), size: drawRect.size), blendMode: .destinationAtop, alpha: 1.0)
        
        currentContext?.restoreGState()
        
        let updatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return updatedImage
    }
    
    func makeOverlayImage(_ imageSize: CGSize) -> UIImage? {
        let mask_color = colors[TheVideoEditor.editSettings.maskColorIdx]

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        mask_color.setFill()
        UIRectFill(CGRect(origin: .zero, size: imageSize))
        let overlayImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return overlayImage
    }

    func makeEmptyOverlayImage(_ imageSize: CGSize) -> UIImage? {
        let mask_color = UIColor.clear
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        mask_color.setFill()
        UIRectFill(CGRect(origin: .zero, size: imageSize))
        let overlayImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return overlayImage
    }

    func updateOverlayImage(_ workingImageView: UIImageView?) {
        //make new overlay image
        let image = makeOverlayImage(TheVideoEditor.initialStillImageSize)!
        
        //get size of imageview and image
        let imageSize = TheVideoEditor.initialStillImageSize
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)

        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        workingImageView!.image!.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height), blendMode: .destinationIn, alpha: 1.0)
        
        let updatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        workingImageView?.image = updatedImage
    }
    
    func restoreMaskImage(_ workingImageView: UIImageView?, _ ptStart: CGPoint, _ ptEnd: CGPoint) {
        //get working image
        let image = workingImageView!.image!
        
        //get size of imageview and image
        let imageViewSize = workingImageView!.bounds.size
        let imageSize = image.size
        
        let fRatio: CGFloat = imageSize.width / imageViewSize.width
        
        //begin the image in context
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let context = UIGraphicsGetCurrentContext()
        
        context?.setBlendMode(.normal)
        
        context?.move(to: CGPoint(x: ptStart.x * fRatio, y: ptStart.y * fRatio))
        context?.addLine(to: CGPoint(x: ptEnd.x * fRatio, y: ptEnd.y * fRatio))
        
        context?.setShadow(
            offset: CGSize(width: 0, height: 0),
            blur: TheVideoEditor.editSettings.brushHardness,
            color: colors[TheVideoEditor.editSettings.maskColorIdx].cgColor
        )
        context?.setLineCap(.round)
        context?.setLineWidth(TheVideoEditor.editSettings.brushSize * fRatio)
        context?.setStrokeColor(colors[TheVideoEditor.editSettings.maskColorIdx].withAlphaComponent(TheVideoEditor.editSettings.brushOpacity / 100.0).cgColor)
        context?.strokePath()
        
        let updatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        workingImageView?.image = updatedImage
    }
    
    func eraseMaskImage(_ workingImageView: UIImageView?, _ ptStart: CGPoint, _ ptEnd: CGPoint) {
        //get working image
        let image = workingImageView!.image!
        
        //get size of imageview and image
        let imageViewSize = workingImageView!.bounds.size
        let imageSize = image.size
        
        let fRatio: CGFloat = imageSize.width / imageViewSize.width
        
        //begin the image in context
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let context = UIGraphicsGetCurrentContext()

        context?.setBlendMode(.destinationOut)
        
        context?.move(to: CGPoint(x: ptStart.x * fRatio, y: ptStart.y * fRatio))
        context?.addLine(to: CGPoint(x: ptEnd.x * fRatio, y: ptEnd.y * fRatio))
        
        context?.setShadow(
            offset: CGSize(width: 0, height: 0),
            blur: TheVideoEditor.editSettings.brushHardness,
            color: colors[TheVideoEditor.editSettings.maskColorIdx].cgColor
        )
        context?.setLineCap(.round)
        context?.setLineWidth(TheVideoEditor.editSettings.brushSize * fRatio)
        context?.setStrokeColor(colors[TheVideoEditor.editSettings.maskColorIdx].withAlphaComponent(TheVideoEditor.editSettings.brushOpacity / 100.0).cgColor)
        context?.strokePath()

        let updatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        workingImageView?.image = updatedImage
    }
    
    func getRealImageFromMask(_ workingImageView: UIImageView?, _ maskImageView: UIImageView?) {
        let image = TheImageProcesser.getCorrectStillImage() //TheVideoEditor.stillImage
        let maskImage = maskImageView?.image
        
        let imageSize = image.size

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)

        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        maskImage!.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height), blendMode: .destinationIn, alpha: 1.0)
        
        let updatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()

        workingImageView?.image = updatedImage
    }
    
    func makeDrawingImageFromMask(_ maskImageView: UIImageView?) -> UIImage? {
        let image = TheImageProcesser.getCorrectStillImage() //TheVideoEditor.stillImage
        let maskImage = maskImageView?.image
        
        let imageSize = image.size
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        maskImage!.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height), blendMode: .destinationIn, alpha: 1.0)
        
        let updatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return updatedImage
    }
}
