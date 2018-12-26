//
//  ThumbnailManager.swift
//  VideoGraph
//
//  Created by Admin on 20/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AVFoundation

let TheThumbnailManager = ThumbnailManager.sharedInstance

class ThumbnailManager: NSObject {
    static let sharedInstance = ThumbnailManager()
    
    var asset: AVAsset? = nil
    private var generator: AVAssetImageGenerator?
    
    override init() {
        super.init()
    }

    func initManager(_ videURL: URL) -> CGSize {
        self.asset = AVAsset(url: videURL)
        
        let thumbSize = getThumbnailFrameSize() ?? CGSize.zero
        setupThumbnailGenerator(thumbSize)
        
        return thumbSize
    }
    
    func getTime(_ position: CGFloat, _ baseWidth: CGFloat) -> CMTime? {
        let normalizedRatio = max(min(1, position / baseWidth), 0)
        let positionTimeValue = Double(normalizedRatio) * Double(asset!.duration.value)
        return CMTime(value: Int64(positionTimeValue), timescale: asset!.duration.timescale)
    }
    
    func getPosition(_ time: CMTime, _ baseWidth: CGFloat) -> CGFloat? {
        let timeRatio = CGFloat(time.value) * CGFloat(asset!.duration.timescale) /
            (CGFloat(time.timescale) * CGFloat(asset!.duration.value))
        return timeRatio * baseWidth
    }
    
    private func setupThumbnailGenerator(_ thumbSize: CGSize) {
        generator = AVAssetImageGenerator(asset: asset!)
        generator?.appliesPreferredTrackTransform = true
        generator?.requestedTimeToleranceAfter = kCMTimeZero
        generator?.requestedTimeToleranceBefore = kCMTimeZero
        generator?.maximumSize = thumbSize
    }
    
    private func getThumbnailFrameSize() -> CGSize? {
        guard let track = asset!.tracks(withMediaType: AVMediaType.video).first else { return nil}
        
        let assetSize = track.naturalSize.applying(track.preferredTransform)
        
        return assetSize
    }
    
    func generateThumbnailImage(_ time: CMTime, _ callback: @escaping (_ image: UIImage?) -> Void) {
        generator?.generateCGImagesAsynchronously(forTimes: [time as NSValue],
                                                  completionHandler: { (_, image, _, _, _) in
                                                    guard let image = image else {
                                                        callback(nil)
                                                        return
                                                    }
                                                    DispatchQueue.main.async {
                                                        self.generator?.cancelAllCGImageGeneration()
                                                        let uiimage = UIImage(cgImage: image)
                                                        callback(uiimage)
                                                    }
        })
    }
}
