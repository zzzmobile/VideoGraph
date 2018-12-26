//
//  VideoFadePlayerView.swift
//  VideoGraph
//
//  Created by Admin on 21/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AVFoundation

class VideoFadePlayerView: UIView {
    var currentTime: CMTime = kCMTimeZero
    
    var playerItem: AVPlayerItem? = nil
    var player: AVPlayer? = nil
    //var videoLayer: AVPlayerLayer? = nil
    
    //variables for getting video data in real time
    private var output: AVPlayerItemVideoOutput!
    private var displayLink: CADisplayLink!
    private var context: CIContext = CIContext(options: [kCIContextWorkingColorSpace : NSNull()])
    private var playerItemObserver: NSKeyValueObservation?

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
    }
    
    func initVideo() {
        deinitVideo()
        
        self.playerItem = AVPlayerItem(url: TheVideoEditor.editSettings.originalVideoURL)
        output = AVPlayerItemVideoOutput(outputSettings: nil)
        self.playerItem?.add(output)

        self.player = AVPlayer(playerItem: self.playerItem!)
        
        if ((player!.rate != 0) && (player!.error == nil)) {
            // player is playing
            return
        }
        
        playerItemObserver = self.playerItem!.observe(\.status) { [weak self] item, _ in
            guard self?.playerItem!.status == .readyToPlay else { return }
            self?.playerItemObserver = nil
            self?.setupDisplayLink()
        }
    }
    
    func stopDisplayLink() {
        displayLink.invalidate()
    }
    
    private func setupDisplayLink() {
        let frameDuration = self.playerItem!.asset.duration
        let nPFS = Int64(frameDuration.timescale) / frameDuration.value
        
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkUpdated(link:)))
        displayLink.preferredFramesPerSecond = Int(nPFS)
        displayLink.add(to: .main, forMode: .commonModes)
    }
    
    func stopVideo() {
        if ((player!.rate != 0) && (player!.error == nil)) {
            // player is playing
            player!.pause()
        }
    }
    
    @objc func playVideoAsOrigin() {
        let duration = CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        let leftOffsetTime = (TheVideoEditor.fTrimLeftOffset / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        let rightOffsetTime = ((TheVideoEditor.baseVideoWidth - TheVideoEditor.fTrimRightOffset) / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        
        let realDuration = duration - leftOffsetTime - rightOffsetTime
        let durationTime = Double(realDuration) / Double(TheVideoEditor.editSettings.speed)
        
        let startTime = CMTime(seconds: durationTime / 2.0 * Double(TheVideoEditor.editSettings.crossFade) + Double(leftOffsetTime), preferredTimescale: self.playerItem!.asset.duration.timescale)
        let endTime = CMTime(seconds: Double(duration - rightOffsetTime), preferredTimescale: self.playerItem!.asset.duration.timescale)

        player!.seek(to: startTime, toleranceBefore: self.playerItem!.asset.duration, toleranceAfter: self.playerItem!.asset.duration)
        playerItem!.forwardPlaybackEndTime = endTime
        self.player?.rate = Float(TheVideoEditor.editSettings.speed)
    }
    
    func playVideoAsReverse() {
        let duration = CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        let leftOffsetTime = (TheVideoEditor.fTrimLeftOffset / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        let rightOffsetTime = ((TheVideoEditor.baseVideoWidth - TheVideoEditor.fTrimRightOffset) / TheVideoEditor.baseVideoWidth) * CGFloat(CMTimeGetSeconds(self.playerItem!.asset.duration))
        
        let realDuration = duration - leftOffsetTime - rightOffsetTime
        let durationTime = Double(realDuration) / Double(TheVideoEditor.editSettings.speed)

        let startTime = CMTime(seconds: durationTime / 2.0 * Double(TheVideoEditor.editSettings.crossFade) + Double(leftOffsetTime), preferredTimescale: self.playerItem!.asset.duration.timescale)
        let endTime = CMTime(seconds: Double(duration - rightOffsetTime), preferredTimescale: self.playerItem!.asset.duration.timescale)

        player!.seek(to: endTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        playerItem!.reversePlaybackEndTime = startTime
        self.player?.rate = -1 * Float(TheVideoEditor.editSettings.speed)
    }
    
    @objc private func displayLinkUpdated(link: CADisplayLink) {
        let time = output.itemTime(forHostTime: CACurrentMediaTime())
        guard output.hasNewPixelBuffer(forItemTime: time),
            let pixbuf = output.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else { return }
        
        let baseImg = CIImage(cvImageBuffer: pixbuf)
        let processCIImage: CIImage = baseImg.clampedToExtent().cropped(to: baseImg.extent)
        
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
