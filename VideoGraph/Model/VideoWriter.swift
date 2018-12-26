//
//  VideoWriter.swift
//  VideoGraph
//
//  Created by Admin on 18/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation

let TheVideoWriter = VideoWriter.sharedInstance

class VideoWriter: NSObject {
    static let sharedInstance = VideoWriter()

    let writerFileName = "captureVideo.mov"
    var presentationTime: CMTime = kCMTimeZero
    var outputSettings   = [String: Any]()
    var videoWriterInput: AVAssetWriterInput!
    var assetWriter: AVAssetWriter!
    var adapter: AVAssetWriterInputPixelBufferAdaptor!
    
    override init() {
        super.init()
    }
    
    func setupAssetWriter (_ videoWidth: Int, _ videoHeight: Int) {
        TheGlobalPoolManager.eraseFile(writerFileName)
        
        outputSettings = [AVVideoCodecKey   : AVVideoCodecType.h264,
                          AVVideoWidthKey   : NSNumber(value: Float(videoWidth)),
                          AVVideoHeightKey  : NSNumber(value: Float(videoHeight))] as [String : Any]
        
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings)
        assetWriter = try? AVAssetWriter(outputURL: TheGlobalPoolManager.getVideoURL(writerFileName), fileType: .mp4)
        assetWriter.add(videoWriterInput)
        
        adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: PixelBufferConverter.getAdapterDictionary() as? [String : Any])
    }
    
    func writeVideoFromData(_ cgImage: CGImage, _ startTime: CMTime) {
        if (assetWriter == nil) {
            return
        }
        
        if (adapter == nil) {
            return
        }
        
        if assetWriter?.status == AVAssetWriterStatus.unknown {
            if (( assetWriter?.startWriting ) != nil) {
                assetWriter?.startWriting()
                assetWriter?.startSession(atSourceTime: startTime)
            }
        }
        
        if assetWriter?.status == AVAssetWriterStatus.writing {
            if (videoWriterInput.isReadyForMoreMediaData == true) {
                if let pixelBuffer = pixelBufferFromCGImage(image: cgImage) {
                    self.adapter.append(pixelBuffer, withPresentationTime: startTime)
                }
            }
        }
    }
    
    func stopAssetWriter(_ block: @escaping (_ bSuccess: Bool, _ outputURL: URL?) -> Void) {
        if (assetWriter == nil) {
            block(false, nil)
            return
        }

        videoWriterInput.markAsFinished()
        assetWriter?.finishWriting(completionHandler: {
            DispatchQueue.main.async {
                if (self.assetWriter?.status == AVAssetWriterStatus.failed) {
                    print("creating movie file is failed ")
                    block(false, nil)
                } else {
                    print(" creating movie file was a success ")
                    block(true, self.assetWriter?.outputURL)
                }
            }
        })
    }

    func pixelBufferFromCGImage(image: CGImage) -> CVPixelBuffer? {
        let frameSize = CGSize(width: image.width, height: image.height)
        
        var pixelBuffer:CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
        
        if status != kCVReturnSuccess {
            return nil
            
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
}

