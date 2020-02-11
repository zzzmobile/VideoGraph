//
//  VideoPlayerView.swift
//  VideoGraph
//
//  Created by Admin on 21/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    var videoThumbnailView: VideoThumbnailsView? = nil
    var fadePlayerView: VideoFadePlayerView? = nil
    
    var currentTime: CMTime = CMTime.zero
    
    var playerItem: AVPlayerItem? = nil
    var player: AVPlayer? = nil
    //var videoLayer: AVPlayerLayer? = nil
    
    //variables for getting video data in real time
    private var output: AVPlayerItemVideoOutput!
    private var displayLink: CADisplayLink!
    private var context: CIContext = CIContext(options: [CIContextOption.workingColorSpace : NSNull()])
    private var playerItemObserver: NSKeyValueObservation?

    var nPlayingIdx: Int = 0
    
    deinit {
        deinitVideo()
    }
    
    func deinitVideo() {
        NotificationCenter.default.removeObserver(self)
        
        if (player == nil) {
            return
        }
        
        if ((player!.rate != 0) && (player!.error == nil)) {
            // player is playing
            player!.pause()
            player!.rate = 0
        }
        
        stopDisplayLink()
        
        playerItem = nil
        
        player!.replaceCurrentItem(with: nil)
        player = nil
        
        self.fadePlayerView?.deinitVideo()
    }
    
    func playVideo(_ thumbnailView: VideoThumbnailsView?, _ fadePlayerView: VideoFadePlayerView?) {
        deinitVideo()
        
        nPlayingIdx = 0
        
        self.videoThumbnailView = thumbnailView
        self.fadePlayerView = fadePlayerView
        
        NotificationCenter.default.addObserver(self, selector: #selector(restartPlayVideo), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedEditVideoSettings), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        self.playerItem = AVPlayerItem(url: TheVideoEditor.editSettings.originalVideoURL)
        output = AVPlayerItemVideoOutput(outputSettings: nil)
        self.playerItem?.add(output)

        self.player = AVPlayer(playerItem: self.playerItem!)
        
        /*
        self.videoLayer = AVPlayerLayer(player: self.player!)
        self.videoLayer?.backgroundColor = UIColor.black.cgColor
        self.videoLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        self.layer.addSublayer(self.videoLayer!)
        self.videoLayer!.frame = self.bounds
        */
        
        if ((player!.rate != 0) && (player!.error == nil)) {
            // player is playing
            return
        }
        
        playerItemObserver = self.playerItem!.observe(\.status) { [weak self] item, _ in
            guard self?.playerItem!.status == .readyToPlay else { return }
            self?.playerItemObserver = nil
            self?.setupDisplayLink()
        }

        self.fadePlayerView?.initVideo()

        playVideoAsOrigin()

        if (self.videoThumbnailView != nil) {
            self.videoThumbnailView?.doIndicatorAnimation()
        }

        endCrossFade()
        beginCrossFade()
    }
    
    @objc func endCrossFade() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    func beginCrossFade() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0.6
        }

        let duration = CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        let leftOffsetTime = (TheVideoEditor.fTrimLeftOffset / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        let rightOffsetTime = ((TheVideoEditor.baseVideoWidth - TheVideoEditor.fTrimRightOffset) / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        
        let realDuration = duration - leftOffsetTime - rightOffsetTime

        let durationTime = Double(realDuration) / Double(TheVideoEditor.editSettings.speed)
        
        let delayTime = Double(TheVideoEditor.editSettings.delay / TheVideoEditor.editSettings.speed) + durationTime / 2.0 * Double(TheVideoEditor.editSettings.crossFade)

        self.perform(#selector(endCrossFade), with: nil, afterDelay: delayTime)
    }
    
    func stopDisplayLink() {
        displayLink.invalidate()
    }
    
    private func setupDisplayLink() {
        let frameDuration = self.playerItem!.asset.duration
        let nPFS = Int64(frameDuration.timescale) / frameDuration.value
        
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkUpdated(link:)))
        displayLink.preferredFramesPerSecond = Int(nPFS)
        displayLink.add(to: .main, forMode: .common)
    }
    
    func stopVideo() {
        if ((player!.rate != 0) && (player!.error == nil)) {
            // player is playing
            player!.pause()
        }
        
        nPlayingIdx = 0
        
        let leftOffsetTime = (TheVideoEditor.fTrimLeftOffset / videoThumbnailView!.frame.width) * CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        let startTime = CMTime(seconds: Double(leftOffsetTime), preferredTimescale: self.playerItem!.asset.duration.timescale)
        self.player!.seek(to: startTime)

        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        endCrossFade()

        if (self.videoThumbnailView != nil) {
            self.videoThumbnailView?.stopIndicatorAnimation()
        }

        self.fadePlayerView?.stopVideo()
    }
    
    @objc func restartPlayVideo() {
        if ((player!.rate != 0) && (player!.error == nil)) {
            // player is playing
            player!.pause()
        }

        nPlayingIdx = 0
        
        let leftOffsetTime = (TheVideoEditor.fTrimLeftOffset / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        let startTime = CMTime(seconds: Double(leftOffsetTime), preferredTimescale: self.playerItem!.asset.duration.timescale)
        self.player!.seek(to: startTime)

        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        endCrossFade()

        let delayTime = Double(TheVideoEditor.editSettings.delay / TheVideoEditor.editSettings.speed)
        self.perform(#selector(playVideoAsOrigin), with: nil, afterDelay: delayTime)
        
        if (self.videoThumbnailView != nil) {
            self.videoThumbnailView?.doIndicatorAnimation()
        }
    }
    
    @objc func playVideoAsOrigin() {
        let duration = CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        let leftOffsetTime = (TheVideoEditor.fTrimLeftOffset / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        let rightOffsetTime = ((TheVideoEditor.baseVideoWidth - TheVideoEditor.fTrimRightOffset) / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))

        let realDuration = duration - leftOffsetTime - rightOffsetTime
        
        if (Double(realDuration) <= Double(TheVideoEditor.editSettings.delay)) {
            //delay is bigger than video duration
            continuePlaying()
        } else {
            let startTime = CMTime(seconds: Double(TheVideoEditor.editSettings.delay + leftOffsetTime), preferredTimescale: self.playerItem!.asset.duration.timescale)
            let endTime = CMTime(seconds: Double(duration - rightOffsetTime), preferredTimescale: self.playerItem!.asset.duration.timescale)
            
            player!.seek(to: startTime, toleranceBefore: self.playerItem!.asset.duration, toleranceAfter: self.playerItem!.asset.duration)
            playerItem!.forwardPlaybackEndTime = endTime
            self.player?.rate = Float(TheVideoEditor.editSettings.speed)
            
            self.fadePlayerView?.playVideoAsOrigin()
            
            endCrossFade()
            beginCrossFade()
        }
    }
    
    func playVideoAsReverse() {
        let duration = CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        let leftOffsetTime = (TheVideoEditor.fTrimLeftOffset / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        let rightOffsetTime = ((TheVideoEditor.baseVideoWidth - TheVideoEditor.fTrimRightOffset) / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        
        let realDuration = duration - leftOffsetTime - rightOffsetTime
        
        if (Double(realDuration) <= Double(TheVideoEditor.editSettings.delay)) {
            let delayTime = Double(TheVideoEditor.editSettings.delay / TheVideoEditor.editSettings.speed)
            self.perform(#selector(continuePlaying), with: nil, afterDelay: delayTime)
        } else {
            let startTime = CMTime(seconds: Double(TheVideoEditor.editSettings.delay + leftOffsetTime), preferredTimescale: self.playerItem!.asset.duration.timescale)
            let endTime = CMTime(seconds: Double(duration - rightOffsetTime), preferredTimescale: self.playerItem!.asset.duration.timescale)
            
            player!.seek(to: endTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            playerItem!.reversePlaybackEndTime = startTime
            self.player?.rate = -1 * Float(TheVideoEditor.editSettings.speed)
            
            self.fadePlayerView?.playVideoAsReverse()
            
            endCrossFade()
            beginCrossFade()
        }
    }
    
    @objc func finishedPlaying(_ myNotification: Notification) {
        guard let p = myNotification.object as? AVPlayerItem, p == self.playerItem else {
            return
        }
        
        self.fadePlayerView?.stopVideo()
        
        if (nPlayingIdx % 2 == 1 && TheVideoEditor.editSettings.repeatMode == .Bounce) {
            //needs to wait during delay seconds
            let delayTime = Double(TheVideoEditor.editSettings.delay / TheVideoEditor.editSettings.speed)

            self.perform(#selector(continuePlaying), with: nil, afterDelay: delayTime)
        } else {
            continuePlaying()
        }
    }
    
    @objc func continuePlaying() {
        self.fadePlayerView?.stopVideo()

        nPlayingIdx += 1
        if (nPlayingIdx == 100) {
            nPlayingIdx = 0
        }

        let leftOffsetTime = (TheVideoEditor.fTrimLeftOffset / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        let startTime = CMTime(seconds: Double(leftOffsetTime), preferredTimescale: self.playerItem!.asset.duration.timescale)

        let delayTime = Double(TheVideoEditor.editSettings.delay / TheVideoEditor.editSettings.speed)

        if (TheVideoEditor.editSettings.repeatMode == .Bounce) {
            if (nPlayingIdx % 2 == 0) {
                //play video
                self.player!.seek(to: startTime)
                self.perform(#selector(playVideoAsOrigin), with: nil, afterDelay: delayTime)
                
                if (self.videoThumbnailView != nil) {
                    self.videoThumbnailView?.doIndicatorAnimation()
                }
            } else {
                //play video in reverse
                self.playVideoAsReverse()
                
                if (self.videoThumbnailView != nil) {
                    self.videoThumbnailView?.doIndicatorAnimation(true)
                }
            }
        } else {
            //play video
            self.player!.seek(to: startTime)
            self.perform(#selector(playVideoAsOrigin), with: nil, afterDelay: delayTime)
            
            if (self.videoThumbnailView != nil) {
                self.videoThumbnailView?.doIndicatorAnimation()
            }
        }
    }

    @objc private func displayLinkUpdated(link: CADisplayLink) {
        autoreleasepool {
            let time = output.itemTime(forHostTime: CACurrentMediaTime())
            guard output.hasNewPixelBuffer(forItemTime: time),
                let pixbuf = output.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else { return }
            
            let baseImg = CIImage(cvImageBuffer: pixbuf)
            var processCIImage: CIImage = baseImg.clampedToExtent().cropped(to: baseImg.extent)
            
            if (!TheVideoEditor.bViewOriginalVideo) {
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
                    
                    processCIImage = processCIImage.applyingFilter("CIColorMatrix", parameters: ["inputRVector": CIVector(x: nR, y: 0.0, z: 0.0, w: 0.0),
                                                                                                 "inputGVector": CIVector(x: 0.0, y: nG, z: 0.0, w: 0.0),
                                                                                                 "inputBVector": CIVector(x: 0.0, y: 0.0, z: nB, w: 0.0),
                                                                                                 "inputAVector": CIVector(x: 0.0, y: 0.0, z: 0.0, w: (TheVideoEditor.editSettings.toneCurveMode == .RGB ? 1.0 : 0.4))])
                    processCIImage = processCIImage.applyingFilter("CIGammaAdjust", parameters: ["inputPower": nGamma])
                    
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
                    
                    //print("whites - \(nWhiteFilterValue), blacks - \(nBlackFilterValue), highlights - \(nHighlightFilterValue), shadows - \(nShadowFilterValue)")
                }
            }
            
            guard var cgImg = context.createCGImage(processCIImage, from: processCIImage.extent) else {
                print("failed to make filter image")
                return
            }
            
            if (!TheVideoEditor.bViewOriginalVideo) {
                cgImg = TheVideoEditor.cropImageWithCropSettings(cgImg)!
            }
            
            layer.contents = cgImg
        }
    }

}
