//
//  VideoThumbnailsView.swift
//  VideoGraph
//
//  Created by Admin on 20/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AVFoundation

let TOTAL_THUMBNAILS_COUNT: Int = 10
let INDICATOR_WIDTH: CGFloat = 1.0

class VideoThumbnailsView: UIView {
    private var generator: AVAssetImageGenerator?
    var asset: AVAsset? = nil
    var thumbSize: CGSize = .zero
    var indicator: UIView? = nil
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
    }
    
    init(_ frame: CGRect) {
        super.init(frame: frame)
        
        self.asset = AVAsset(url: TheVideoEditor.editSettings.originalVideoURL)
        self.thumbSize = CGSize(width: frame.width / CGFloat(TOTAL_THUMBNAILS_COUNT), height: frame.height)
        
        makeThumbViews()
        addIndicatorView()
        
        let timesForThumbnail = getThumbnailTimes()
        generateImages(timesForThumbnail, TOTAL_THUMBNAILS_COUNT)
    }
    
    func makeThumbViews() {
        for nIdx in 0..<TOTAL_THUMBNAILS_COUNT {
            let thumbView = UIImageView(frame: CGRect(x: CGFloat(nIdx) * thumbSize.width, y: 0.0, width: thumbSize.width, height: thumbSize.height))
            thumbView.contentMode = .scaleAspectFill
            thumbView.clipsToBounds = true
            thumbView.tag = 40 + nIdx
            self.addSubview(thumbView)
        }
    }
    
    func addIndicatorView() {
        self.indicator = UIView(frame: CGRect(x: 0.0, y: 0.0, width: INDICATOR_WIDTH, height: thumbSize.height))
        self.indicator?.backgroundColor = UIColor.yellow
        self.addSubview(indicator!)
    }
    
    func stopIndicatorAnimation() {
        self.indicator?.layer.removeAllAnimations()
    }
    
    func doIndicatorAnimation(_ bReverse: Bool = false) {
        print("start animation -  reverse: \(bReverse)")
        stopIndicatorAnimation()
        
        var ptStart: CGPoint = .zero
        var ptEnd: CGPoint = .zero
        
        if (bReverse) {
            ptStart = CGPoint(x: TheVideoEditor.fTrimRightOffset, y: thumbSize.height / 2.0)
            ptEnd = CGPoint(x: TheVideoEditor.fTrimLeftOffset, y: thumbSize.height / 2.0)
        } else {
            ptStart = CGPoint(x: TheVideoEditor.fTrimLeftOffset, y: thumbSize.height / 2.0)
            ptEnd = CGPoint(x: TheVideoEditor.fTrimRightOffset, y: thumbSize.height / 2.0)
        }
        
        self.indicator?.center = ptStart
        
        let duration = CGFloat(CMTimeGetSeconds(self.asset!.duration))
        let leftOffsetTime = (TheVideoEditor.fTrimLeftOffset / self.frame.width) * duration
        let rightOffsetTime = ((self.frame.width - TheVideoEditor.fTrimRightOffset) / self.frame.width) * duration
        let realDuration = duration - leftOffsetTime - rightOffsetTime
        
        let durationTime = Double(realDuration) / Double(TheVideoEditor.editSettings.speed)
        let delayTime = Double(TheVideoEditor.editSettings.delay / TheVideoEditor.editSettings.speed)
        
        UIView.animate(withDuration: (durationTime >= delayTime ? durationTime : delayTime), delay: 0.0, options: .curveLinear, animations: {
            self.indicator?.center = ptEnd
        }, completion: nil)
    }
    
    private func getThumbnailTimes() -> [NSValue] {
        let timeIncrement = (asset!.duration.seconds * 1000) / Double(TOTAL_THUMBNAILS_COUNT)
        var timesForThumbnails = [NSValue]()
        
        for index in 0..<TOTAL_THUMBNAILS_COUNT {
            let cmTime = CMTime(value: Int64(timeIncrement * Float64(index)), timescale: 1000)
            let nsValue = NSValue(time: cmTime)
            timesForThumbnails.append(nsValue)
        }
        
        return timesForThumbnails
    }
    
    private func generateImages(_ times: [NSValue], _ visibleThumnails: Int) {
        generator = AVAssetImageGenerator(asset: asset!)
        generator?.appliesPreferredTrackTransform = true
        let scaledSize = CGSize(width: thumbSize.width * UIScreen.main.scale, height: thumbSize.height *  UIScreen.main.scale)
        generator?.maximumSize = scaledSize
        
        var count = 0
        let handler: AVAssetImageGeneratorCompletionHandler = { [weak self] (_, cgimage, _, result, error) in
            if let cgimage = cgimage, error == nil && result == AVAssetImageGenerator.Result.succeeded {
                DispatchQueue.main.async(execute: { [weak self] () -> Void in
                    if count == 0 {
                        self?.displayFirstImage(cgimage, visibleThumbnails: visibleThumnails)
                    }
                    
                    self?.displayImage(cgimage, at: count)
                    
                    count += 1
                })
            }
        }
        
        generator?.generateCGImagesAsynchronously(forTimes: times, completionHandler: handler)
    }
    
    private func displayFirstImage(_ cgImage: CGImage, visibleThumbnails: Int) {
        for i in 0...visibleThumbnails {
            displayImage(cgImage, at: i)
        }
    }
    
    private func displayImage(_ cgImage: CGImage, at index: Int) {
        if let thumbView = self.viewWithTag(40 + index) as? UIImageView {
            let uiimage = UIImage(cgImage: cgImage, scale: 1.0, orientation: UIImage.Orientation.up)
            thumbView.image = uiimage
        }
    }
    
}
