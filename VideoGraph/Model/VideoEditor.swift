//
//  VideoEditor.swift
//  VideoGraph
//
//  Created by Admin on 18/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AVFoundation

let TheVideoEditor = VideoEditor.sharedInstance

class VideoEditor: NSObject {
    static let sharedInstance = VideoEditor()
    
    var baseVideoWidth: CGFloat = 0.0
    
    var editSettings: EditSettings = EditSettings.init()
    var stillImage: UIImage? = nil
    var initialStillImageSize: CGSize = .zero
    
    var bChangedToneCurve: Bool = false
    var bChangedTemperature: Bool = false
    var bChangedTint: Bool = false
    
    var bViewOriginalVideo: Bool = false
    
    var cropSettings: CropSettings = CropSettings.init()
    var priorCropSettings: CropSettings = CropSettings.init()
    
    var selectedFontObjectIdx: Int = -1
    var fontObjects: [FontObject] = []
    
    var originalMaskImageForUndo: UIImage? = nil
    var currentMaskImageForUndo: UIImage? = nil
    
    var fTrimLeftOffset: CGFloat = 0.0
    var fTrimRightOffset: CGFloat = 0.0
    
    override init() {
        super.init()
    }
    
    func initEditor() {
        TheUndoManager.resetManager()
        
        self.baseVideoWidth = UIScreen.main.bounds.width - 48.0 - 120
        
        self.fTrimLeftOffset = 0.0
        self.fTrimRightOffset = UIScreen.main.bounds.width - 48.0 - 120
        
        self.editSettings = EditSettings.init()
        self.cropSettings = CropSettings.init()
        self.priorCropSettings = CropSettings.init()
        
        bChangedTint = false
        bChangedTemperature = false
        bChangedToneCurve = false
        
        self.selectedFontObjectIdx = -1
        self.fontObjects.removeAll()
    }
    
    func initEditorWithProject(_ project: Project) {
        TheUndoManager.resetManager()
        
        self.baseVideoWidth = UIScreen.main.bounds.width - 48.0 - 120

        self.fTrimLeftOffset = project.leftTrimOffset
        self.fTrimRightOffset = project.rightTrimOffset

        self.stillImage = project.stillImage
        self.initialStillImageSize = project.stillImageSize
        
        self.editSettings = project.editSettings
        self.cropSettings = project.cropSettings
        self.priorCropSettings = project.priorCropSettings
        
        bChangedTint = project.bChangedTint
        bChangedTemperature = project.bChangedTemperature
        bChangedToneCurve = project.bChangedToneCurve
        
        self.selectedFontObjectIdx = project.selectedObjectIdx
        self.fontObjects = project.fontObjects
        
        self.originalMaskImageForUndo = project.originalMaskImage
        self.currentMaskImageForUndo = project.currentMaskImage
    }
    
    func setupOriginalVideosInSettings(_ originalVideoName: String) {
        self.editSettings.originalVideoName = originalVideoName
    }
    
    func cropImageWithCropSettings(_ cgImg: CGImage) -> CGImage? {
        var croppedCGImage = cgImg
        
        if (TheVideoEditor.cropSettings.bUpdated) {
            let imageRef = croppedCGImage.transformedImage(TheVideoEditor.cropSettings.entireTransform,
                                                  sourceSize: TheVideoEditor.stillImage!.size,
                                                  cropSize: TheVideoEditor.cropSettings.cropSize,
                                                  imageViewSize: TheVideoEditor.cropSettings.imageViewSize)
            
            var tempImage = UIImage(cgImage: imageRef)
            if (TheVideoEditor.cropSettings.fliped) {
                tempImage = tempImage.flipImageLeftRight()!
            }
            
            croppedCGImage = tempImage.cgImage!
        }
        
        return croppedCGImage
    }
    
    func reverse(_ videoURL: URL, callback: @escaping (_ reverselURL: URL?) -> Void) {
        // Initialize the reader
        let videoAsset: AVAsset = AVAsset(url: videoURL)

        var reader: AVAssetReader! = nil
        do {
            reader = try AVAssetReader(asset: videoAsset)
        } catch {
            print("could not initialize reader.")
            return
        }
        
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first! as AVAssetTrack
        let readerOutputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
        reader.add(readerOutput)
        
        reader.startReading()
        
        // read in samples
        
        var samples: [CMSampleBuffer] = []
        while let sample = readerOutput.copyNextSampleBuffer() {
            samples.append(sample)
        }
        
        // Initialize the writer
        let videoFileName = "\(Date().millisecondsSince1970).mp4"
        TheGlobalPoolManager.eraseFile(videoFileName)
        let outputURL = TheGlobalPoolManager.getVideoURL(videoFileName)

        let writer: AVAssetWriter
        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        let videoCompositionProps = [AVVideoAverageBitRateKey: videoTrack.estimatedDataRate]
        let writerOutputSettings = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoTrack.naturalSize.width,
            AVVideoHeightKey: videoTrack.naturalSize.height,
            AVVideoCompressionPropertiesKey: videoCompositionProps
            ] as [String : Any]
        
        let writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: writerOutputSettings)
        writerInput.expectsMediaDataInRealTime = false
        writerInput.transform = videoTrack.preferredTransform
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
        
        writer.add(writerInput)
        writer.startWriting()
        writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(samples.first!))
        
        for (index, sample) in samples.enumerated() {
            let presentationTime = CMSampleBufferGetPresentationTimeStamp(sample)
            let imageBufferRef = CMSampleBufferGetImageBuffer(samples[samples.count - 1 - index])
            while !writerInput.isReadyForMoreMediaData {
                Thread.sleep(forTimeInterval: 0.1)
            }
            pixelBufferAdaptor.append(imageBufferRef!, withPresentationTime: presentationTime)
            
        }
        
        writer.finishWriting {
            DispatchQueue.main.async(execute: {
                if (writer.status == .completed) {
                    callback(outputURL)
                } else {
                    callback(nil)
                }
            })
        }
    }
    
    func crop(_ videoURL: URL, _ nFPS: Int32, _ strRatio: String, _ callback: @escaping (_ newUrl: URL?) -> Void) {
        // Get input clip
        let videoAsset: AVAsset = AVAsset(url: videoURL)
        let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first! as AVAssetTrack
        let naturalSize = clipVideoTrack.naturalSize

        let ratios = strRatio.components(separatedBy: ":")
        let nWidthRatio = Int(ratios[1])!
        let nHeightRatio = Int(ratios[0])!
        //let nWidthRatio = Int(ratios[0])!
        //let nHeightRatio = Int(ratios[1])!
        
        var newWidth: CGFloat = naturalSize.width
        var newHeight = naturalSize.width / CGFloat(nWidthRatio) * CGFloat(nHeightRatio)
        newWidth = CGFloat(Int(newWidth / 4) * 4)
        newHeight = CGFloat(Int(newHeight / 4) * 4)
        
        // Make video to square
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize( width: newWidth, height: newHeight)
        videoComposition.frameDuration = CMTimeMake(1, (nFPS == 24 ? 30 : nFPS))
        
        // Rotate to portrait
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let transform1 = CGAffineTransform(translationX: 0, y: -(naturalSize.height - newHeight) / 2)
        //let transform2 = transform1.rotated(by: CGFloat( Double.pi / 2.0 ) )
        transformer.setTransform(transform1, at: kCMTimeZero)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        instruction.layerInstructions = [transformer]
        
        videoComposition.instructions = [instruction]
        
        // Export
        let videoFileName = "\(Date().millisecondsSince1970).mp4"
        TheGlobalPoolManager.eraseFile(videoFileName)
        let croppedOutputFileUrl = TheGlobalPoolManager.getVideoURL(videoFileName)
        let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)!
        exporter.videoComposition = videoComposition
        exporter.outputURL = croppedOutputFileUrl
        exporter.outputFileType = .mp4
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async(execute: {
                if (exporter.status == .completed) {
                    callback(croppedOutputFileUrl)
                } else {
                    callback(nil)
                }
            })
        }
    }
    
    func removeAudioAndFixOrientation(_ videoURL: URL, _ callback: @escaping (_ newUrl: URL?) -> Void) {
        let asset = AVURLAsset(url: videoURL)
        
        let originalVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: 1)
        let timeRange = originalVideoTrack.timeRange
        do {
            try videoTrack?.insertTimeRange(timeRange, of: originalVideoTrack, at: kCMTimeZero)
        } catch {
            
        }
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = timeRange
        
        let firstlayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack!)
        let firstAssetTrack = originalVideoTrack
        
        
        //MARK - Fix Rotation
        var firstAssetOrientation_ = UIImageOrientation.up
        
        var isFirstAssetPortrait_ = false
        
        let firstTransform = videoTrack!.preferredTransform;
        if firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0 {
            firstAssetOrientation_ = UIImageOrientation.right;
            isFirstAssetPortrait_ = true;
        }
        if (firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0) {
            firstAssetOrientation_ =  UIImageOrientation.left;
            isFirstAssetPortrait_ = true;
        }
        if (firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0) {
            firstAssetOrientation_ =  UIImageOrientation.up;
        }
        if (firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {
            firstAssetOrientation_ = UIImageOrientation.down;
        }
        
        firstlayerInstruction.setTransform(asset.preferredTransform, at: kCMTimeZero)
        mainInstruction.layerInstructions = [firstlayerInstruction]
        
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1, 30)
        videoComposition.instructions = [mainInstruction]
        
        var naturalSizeFirst = CGSize()
        
        if(isFirstAssetPortrait_){
            naturalSizeFirst = CGSize(width: videoTrack!.naturalSize.height, height: videoTrack!.naturalSize.width);
        } else {
            naturalSizeFirst = videoTrack!.naturalSize;
        }
        videoComposition.renderSize = naturalSizeFirst
        
        let videoFileName = "\(Date().millisecondsSince1970).mp4"
        TheGlobalPoolManager.eraseFile(videoFileName)
        let outputUrl = TheGlobalPoolManager.getVideoURL(videoFileName)
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        exporter.videoComposition = videoComposition
        exporter.outputURL = outputUrl
        exporter.outputFileType = .mp4
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async(execute: {
                if (exporter.status == .completed) {
                    callback(outputUrl)
                } else {
                    callback(nil)
                }
            })
        }
    }
    
    func cropFromGalleryVideo(_ videoURL: URL, _ nFPS: Int32, _ strRatio: String, _ callback: @escaping (_ newUrl: URL?) -> Void) {
        // Get input clip
        let videoAsset: AVAsset = AVAsset(url: videoURL)
        let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first! as AVAssetTrack
        let naturalSize = clipVideoTrack.naturalSize
        
        let ratios = strRatio.components(separatedBy: ":")
        let nWidthRatio = Int(ratios[1])!
        let nHeightRatio = Int(ratios[0])!
        //let nWidthRatio = Int(ratios[0])!
        //let nHeightRatio = Int(ratios[1])!
        
        var newWidth: CGFloat = naturalSize.width
        var newHeight = naturalSize.width / CGFloat(nWidthRatio) * CGFloat(nHeightRatio)
        newWidth = CGFloat(Int(newWidth / 4) * 4)
        newHeight = CGFloat(Int(newHeight / 4) * 4)
        
        // Make video to square
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize( width: newWidth, height: newHeight)
        videoComposition.frameDuration = CMTimeMake(1, (nFPS == 24 ? 30 : nFPS))
        
        // Rotate to portrait
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let transform1 = CGAffineTransform(translationX: 0, y: -(naturalSize.height - newHeight) / 2)
        //let transform2 = transform1.rotated(by: CGFloat( Double.pi / 2.0 ) )
        transformer.setTransform(transform1, at: kCMTimeZero)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        instruction.layerInstructions = [transformer]
        
        videoComposition.instructions = [instruction]
        
        // Export
        let videoFileName = "\(Date().millisecondsSince1970).mp4"
        TheGlobalPoolManager.eraseFile(videoFileName)
        let croppedOutputFileUrl = TheGlobalPoolManager.getVideoURL(videoFileName)
        let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)!
        exporter.videoComposition = videoComposition
        exporter.outputURL = croppedOutputFileUrl
        exporter.outputFileType = .mp4
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async(execute: {
                if (exporter.status == .completed) {
                    callback(croppedOutputFileUrl)
                } else {
                    callback(nil)
                }
            })
        }
    }
    // MARK: - Video Magic Functions
    func makePreviewVideo(_ initialURL: URL, _ outputSize: CGSize, _ maskImage: UIImage, _ fDelay: CGFloat, _ completion: @escaping (_ url: URL?, _ bSuccess: Bool) -> Void) {
        self.applyFiltersIntoVideo(initialURL) { (videoURL1, bSuccess) in
            if (bSuccess) {
                self.cropVideoWithTransform(videoURL1!, outputSize, { (videoURL2, bSuccess) in
                    if (bSuccess) {
                        self.addDelayIntoVideo(videoURL2!, { (videoURL3, bSuccess) in
                            if (bSuccess) {
                                self.addOverlayIntoVideo(videoURL3!, maskImage, { (finalVideoURL, bSuccess) in
                                    if (bSuccess) {
                                        completion(finalVideoURL, true)
                                    } else {
                                        completion(nil, false)
                                    }
                                })
                            } else {
                                completion(nil, false)
                            }
                        })
                    } else {
                        completion(nil, false)
                    }
                })
            } else {
                completion(nil, false)
            }
        }
    }
    
    func applyFiltersIntoVideo(_ videoURL: URL, _ completion: @escaping (_ url: URL?, _ bSuccess: Bool) -> Void) {
        let asset = AVAsset(url: videoURL)
        
        let filteredVideoURL = TheGlobalPoolManager.getVideoURL("final_appliedFilter.mp4")
        TheGlobalPoolManager.eraseFile("final_appliedFilter.mp4")
        
        var filters: [CIFilter] = []
        
        if (TheVideoEditor.editSettings.filterIdx > 0) {
            let filter = CIFilter(name: TheVideoFilterManager.filterNames[TheVideoEditor.editSettings.filterIdx])
            filters.append(filter!)
        }
        
        let colorControlsFilter = CIFilter(name: "CIColorControls", withInputParameters: [kCIInputSaturationKey: TheVideoEditor.editSettings.saturation,
                                                                                          kCIInputBrightnessKey: TheVideoEditor.editSettings.brightness,
                                                                                          kCIInputContrastKey: TheVideoEditor.editSettings.contrast])
        filters.append(colorControlsFilter!)
        
        let vignetteFilter = CIFilter(name: "CIVignette", withInputParameters: [kCIInputIntensityKey: TheVideoEditor.editSettings.intensity,
                                                                                kCIInputRadiusKey: TheVideoEditor.editSettings.radius])
        filters.append(vignetteFilter!)
        
        let exposureFilter = CIFilter(name: "CIExposureAdjust", withInputParameters: [kCIInputEVKey: TheVideoEditor.editSettings.exposure])
        filters.append(exposureFilter!)
        
        if (TheVideoEditor.bChangedTemperature) {
            let tempColor = TheGlobalPoolManager.getTempColorBetweenTwoColors((TheVideoEditor.editSettings.temperature + 10.0) / 20.0)
            let tempFilter = CIFilter(name: "CIWhitePointAdjust", withInputParameters: [kCIInputColorKey: CIColor(color: tempColor)])
            filters.append(tempFilter!)
        }
        
        if (TheVideoEditor.bChangedTint) {
            let tintColor = TheGlobalPoolManager.getTintColorBetweenTwoColors((TheVideoEditor.editSettings.tint + 10.0) / 20.0)
            let tintFilter = CIFilter(name: "CIWhitePointAdjust", withInputParameters: [kCIInputColorKey: CIColor(color: tintColor)])
            filters.append(tintFilter!)
        }
        
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
                nR = 0.6
                nG = 0.4
                nB = 0.4
                nBlacks = TheVideoEditor.editSettings.blacks_r
                nWhites = TheVideoEditor.editSettings.whites_r
                nShadows = TheVideoEditor.editSettings.shadows_r
                nHighlights = TheVideoEditor.editSettings.highlights_r
                break
            case .G:
                nGamma = 0.5
                nR = 0.4
                nG = 0.6
                nB = 0.4
                nBlacks = TheVideoEditor.editSettings.blacks_g
                nWhites = TheVideoEditor.editSettings.whites_g
                nShadows = TheVideoEditor.editSettings.shadows_g
                nHighlights = TheVideoEditor.editSettings.highlights_g
                break
            case .B:
                nGamma = 0.25
                nR = 0.4
                nG = 0.4
                nB = 0.6
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
            
            let colorMatrixFilter = CIFilter(name: "CIColorMatrix", withInputParameters: ["inputRVector": CIVector(x: nR, y: 0.0, z: 0.0, w: 0.0),
                                                                                          "inputGVector": CIVector(x: 0.0, y: nG, z: 0.0, w: 0.0),
                                                                                          "inputBVector": CIVector(x: 0.0, y: 0.0, z: nB, w: 0.0),
                                                                                          "inputAVector": CIVector(x: 0.0, y: 0.0, z: 0.0, w: (TheVideoEditor.editSettings.toneCurveMode == .RGB ? 1.0 : 0.4))])
            let gammaFilter = CIFilter(name: "CIGammaAdjust", withInputParameters: ["inputPower": nGamma])
            
            //make blacks and whites
            let ValueStep: CGFloat = 10.0
            
            if (nWhites > 0) {
                nWhiteFilterValue = (180.0 - nWhites * ValueStep) / 255.0
            } else if (nBlacks < 0) {
                nWhiteFilterValue = (180.0 - nWhites * ValueStep) / 255.0
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
            
            let colorClampFilter = CIFilter(name: "CIColorClamp", withInputParameters: ["inputMinComponents": CIVector(x: nBlackFilterValue, y: nBlackFilterValue, z: nBlackFilterValue, w: 0.0),
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
            
            let highlightShadowFilter = CIFilter(name: "CIHighlightShadowAdjust", withInputParameters: ["inputHighlightAmount": nHighlightFilterValue,
                                                                                                        "inputShadowAmount": nShadowFilterValue])
            
            filters.append(colorMatrixFilter!)
            filters.append(gammaFilter!)
            filters.append(colorClampFilter!)
            filters.append(highlightShadowFilter!)
        }
        
        let exporter = VideoFilterExport(asset: asset, filters: filters)
        exporter.export(toURL: filteredVideoURL) { (url) in
            completion(url, (url == nil ? false : true))
        }
    }
    
    func cropVideoWithTransform(_ videoURL: URL, _ outputSize: CGSize, _ completion: @escaping (_ url: URL?, _ bSuccess: Bool) -> Void) {
        let outputURL = TheGlobalPoolManager.getVideoURL("final_croppedVideo.mp4")
        TheGlobalPoolManager.eraseFile("final_croppedVideo.mp4")
        
        let videoAsset = AVAsset(url: videoURL)
        
        let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first! as AVAssetTrack
        
        // Make video to square
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = outputSize
        videoComposition.frameDuration = clipVideoTrack.minFrameDuration
        
        // transform
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        
        let transform = TheVideoEditor.cropSettings.entireTransform
        let scrollViewOffset = TheVideoEditor.cropSettings.scrollViewContentOffset
        let bFliped = TheVideoEditor.cropSettings.fliped
        let angle = TheVideoEditor.cropSettings.angle - CGFloat(TheVideoEditor.cropSettings.rotateCnt) * IGRRadianAngle.toRadians(90.0)
        
        let scaleX = sqrt(Double(transform.a * transform.a + transform.c * transform.c))
        let scaleY = sqrt(Double(transform.b * transform.b + transform.d * transform.d))
        
        var translation_scaleX: CGFloat = 1.0
        var translation_scaleY: CGFloat = 1.0
        if (TheVideoEditor.cropSettings.bUpdated) {
            translation_scaleX = outputSize.width / TheVideoEditor.cropSettings.contentViewFrame.width
            translation_scaleY = outputSize.height / TheVideoEditor.cropSettings.contentViewFrame.height
        }
        
        let cropRect = CGRect(x: 0.0, y: 0.0, width: outputSize.width / CGFloat(scaleX), height: outputSize.height / CGFloat(scaleY))
        let updatedCropRect = cropRect.applying(CGAffineTransform(rotationAngle: angle))
        let temp_translationX = (updatedCropRect.size.width - cropRect.size.width) / 2.0
        let temp_translationY = (updatedCropRect.size.height - cropRect.size.height) / 2.0
        
        let extent = CGRect(x: 0, y: 0, width: outputSize.width, height: outputSize.height)
        
        var tx = CGAffineTransform(translationX: extent.width / 2, y: extent.height / 2)
        tx = tx.rotated(by: angle)
        tx = tx.translatedBy(x: -extent.width / 2, y: -extent.height / 2)
        
        if(bFliped){
            tx = tx.scaledBy(x: -1.0, y: 1.0)
            tx = tx.translatedBy(x: -extent.width, y: 0.0)
        }
        
        tx = tx.scaledBy(x: CGFloat(scaleX), y: CGFloat(scaleY))
        tx = tx.translatedBy(x: -translation_scaleX * scrollViewOffset.x - temp_translationX, y: -translation_scaleY * scrollViewOffset.y - temp_translationY)
        
        transformer.setTransform(tx, at: kCMTimeZero)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        // Export
        //add time range
        let duration = CGFloat(CMTimeGetSeconds(videoAsset.duration))
        let leftOffsetTime = (TheVideoEditor.fTrimLeftOffset / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(videoAsset.duration))
        let rightOffsetTime = ((TheVideoEditor.baseVideoWidth - TheVideoEditor.fTrimRightOffset) / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(videoAsset.duration))

        let startTime = CMTime(seconds: Double(leftOffsetTime), preferredTimescale: videoAsset.duration.timescale)
        let endTime = CMTime(seconds: Double(duration - rightOffsetTime), preferredTimescale: videoAsset.duration.timescale)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
        let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)!
        exporter.timeRange = timeRange
        exporter.videoComposition = videoComposition
        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async(execute: {
                if (exporter.status == .completed) {
                    completion(outputURL, true)
                } else {
                    completion(nil, false)
                }
            })
        }
    }
    
    func addDelayIntoVideo(_ videoURL: URL, _ completion: @escaping (_ url: URL?, _ bSuccess: Bool) -> Void) {
        // Initialize the reader
        let videoAsset: AVAsset = AVAsset(url: videoURL)
        
        var reader: AVAssetReader! = nil
        do {
            reader = try AVAssetReader(asset: videoAsset)
        } catch {
            print("could not initialize reader.")
            completion(nil, false)
            return
        }
        
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first! as AVAssetTrack
        let readerOutputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
        reader.add(readerOutput)
        
        reader.startReading()
        
        // read in samples
        var samples: [CMSampleBuffer] = []
        while let sample = readerOutput.copyNextSampleBuffer() {
            samples.append(sample)
        }
        
        // Initialize the writer
        let outputURL = TheGlobalPoolManager.getVideoURL("final_addDelay.mp4")
        TheGlobalPoolManager.eraseFile("final_addDelay.mp4")
        
        let writer: AVAssetWriter
        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        let videoCompositionProps = [AVVideoAverageBitRateKey: videoTrack.estimatedDataRate]
        let writerOutputSettings = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoTrack.naturalSize.width,
            AVVideoHeightKey: videoTrack.naturalSize.height,
            AVVideoCompressionPropertiesKey: videoCompositionProps
            ] as [String : Any]
        
        let writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: writerOutputSettings)
        writerInput.expectsMediaDataInRealTime = false
        writerInput.transform = videoTrack.preferredTransform
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
        
        writer.add(writerInput)
        writer.startWriting()
        writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(samples.first!))
        print("=========start to add delay into video=========")
        for (index, sample) in samples.enumerated() {
            let presentationTime = CMSampleBufferGetPresentationTimeStamp(sample)
            print(CMTimeGetSeconds(presentationTime))
            
            var imageBufferRef = CMSampleBufferGetImageBuffer(samples.first!)
            if (CMTimeGetSeconds(presentationTime) >= 0.0) {
                imageBufferRef = CMSampleBufferGetImageBuffer(samples[index])
            }
            
            while !writerInput.isReadyForMoreMediaData {
                Thread.sleep(forTimeInterval: 0.1)
            }
            pixelBufferAdaptor.append(imageBufferRef!, withPresentationTime: presentationTime)
            
        }
        
        writer.finishWriting {
            DispatchQueue.main.async(execute: {
                if (writer.status == .completed) {
                    completion(outputURL, true)
                } else {
                    completion(nil, false)
                }
            })
        }
    }
    
    func addOverlayIntoVideo(_ videoURL: URL, _ maskImage: UIImage, _ completion: @escaping (_ url: URL?, _ bSuccess: Bool) -> Void) {
        let composition = AVMutableComposition()
        let asset = AVURLAsset(url: videoURL, options: nil)
        
        let track =  asset.tracks(withMediaType: AVMediaType.video)
        let videoTrack:AVAssetTrack = track[0] as AVAssetTrack
        let timerange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        
        let compositionVideoTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())!
        
        do {
            try compositionVideoTrack.insertTimeRange(timerange, of: videoTrack, at: kCMTimeZero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        } catch {
            print(error)
        }
        
        let size = videoTrack.naturalSize
        
        let watermark = maskImage.cgImage
        let watermarklayer = CALayer()
        watermarklayer.contents = watermark
        watermarklayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        watermarklayer.opacity = 1
        
        let videolayer = CALayer()
        videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let parentlayer = CALayer()
        parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentlayer.addSublayer(videolayer)
        parentlayer.addSublayer(watermarklayer)
        
        let layercomposition = AVMutableVideoComposition()
        layercomposition.frameDuration = videoTrack.minFrameDuration
        layercomposition.renderSize = size
        layercomposition.renderScale = 1.0
        layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
        
        let videotrack = composition.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
        
        layerinstruction.setTransform(videoTrack.preferredTransform, at: kCMTimeZero)
        
        instruction.layerInstructions = [layerinstruction]
        layercomposition.instructions = [instruction]
        
        let videoFileName = "\(Date().millisecondsSince1970).mp4"
        TheGlobalPoolManager.eraseFile(videoFileName)
        let outputURL = TheGlobalPoolManager.getVideoURL(videoFileName)

        /*
        let outputURL = TheGlobalPoolManager.getVideoURL("final_addOverlay.mp4")
        TheGlobalPoolManager.eraseFile("final_addOverlay.mp4")
        */
        
        // Export
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        exporter.videoComposition = layercomposition
        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async(execute: {
                if (exporter.status == .completed) {
                    completion(outputURL, true)
                } else {
                    completion(nil, false)
                }
            })
        }
    }
    
    func makeLoopVideo(_ nRepeatCnt: Int, _ videoURL: URL, _ completion: @escaping (_ url: URL?, _ bSuccess: Bool) -> Void) {
        var videos: [URL] = []
        for _ in 0..<nRepeatCnt {
            videos.append(videoURL)
        }
        
        VideoMerger().mergeVideos(withFileURLs: videos, completion: { (url, error) in
            completion(url, (error == nil ? true : false))
        })
    }
    
    func resizeVideo(_ videoURL: URL, _ videoDimension: CGFloat, _ completion: @escaping (_ url: URL?, _ bSuccess: Bool) -> Void) {
        let videoAsset: AVAsset = AVAsset(url: videoURL)
        let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first! as AVAssetTrack
        let naturalSize = clipVideoTrack.naturalSize
        
        let newWidth: CGFloat = videoDimension
        var newHeight: CGFloat = 0.0
        let sizeRatio: CGFloat = videoDimension / naturalSize.width
        
        newHeight = naturalSize.height * sizeRatio
        newHeight = CGFloat(Int(newHeight / 4) * 4)

        /*
        if (naturalSize.width >= naturalSize.height) {
            sizeRatio = videoDimension / naturalSize.width
        } else {
            sizeRatio = videoDimension / naturalSize.height
        }
        
        newWidth = naturalSize.width * sizeRatio
        newHeight = naturalSize.height * sizeRatio
        
        newWidth = CGFloat(Int(newWidth / 4) * 4)
        newHeight = CGFloat(Int(newHeight / 4) * 4)
        */
        
        // Make video to square
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize( width: newWidth, height: newHeight)
        videoComposition.frameDuration = clipVideoTrack.minFrameDuration
        
        // Rotate to portrait
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let transform1 = CGAffineTransform(scaleX: sizeRatio, y: sizeRatio)
        transformer.setTransform(transform1, at: kCMTimeZero)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        instruction.layerInstructions = [transformer]
        
        videoComposition.instructions = [instruction]
        
        let outputURL = TheGlobalPoolManager.getVideoURL("final_resized.mp4")
        TheGlobalPoolManager.eraseFile("final_resized.mp4")

        // Export
        let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)!
        exporter.videoComposition = videoComposition
        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async(execute: {
                if (exporter.status == .completed) {
                    completion(outputURL, true)
                } else {
                    completion(nil, false)
                }
            })
        }
    }
    
    func removeAllTempVideos() {
        TheGlobalPoolManager.eraseFile("final_appliedFilter.mp4")
        TheGlobalPoolManager.eraseFile("final_croppedVideo.mp4")
        TheGlobalPoolManager.eraseFile("final_addDelay.mp4")
        TheGlobalPoolManager.eraseFile("final_addOverlay.mp4")
        TheGlobalPoolManager.eraseFile("final_resized.mp4")
        TheGlobalPoolManager.eraseFile("final_repeatVideo.mp4")
    }
}
