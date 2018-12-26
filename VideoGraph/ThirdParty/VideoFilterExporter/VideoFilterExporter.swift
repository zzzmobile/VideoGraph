/*
   Copyright 2016 Domenico Ottolia

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import Foundation

class VideoFilterExport{
   
   // For implementation in Swift 2.x, look at the history of this file at
   // https://github.com/jojodmo/VideoFilterExporter/blob/cf6fcdb4852eae5a1c8a2ce0887bebfeb0f36a9a/VideoFilterExporter.swift
    
    let asset: AVAsset
    let filters: [CIFilter]
    let context: CIContext
    init(asset: AVAsset, filters: [CIFilter], context: CIContext){
        self.asset = asset
        self.filters = filters
        self.context = context
    }
    
    convenience init(asset: AVAsset, filters: [CIFilter]){
        let eagl = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        let context = CIContext(eaglContext: eagl!, options: [kCIContextWorkingColorSpace : NSNull()])
        
        self.init(asset: asset, filters: filters, context: context)
    }
    
    func export(toURL url: URL, callback: @escaping (_ url: URL?) -> Void){
        guard let videoTrack: AVAssetTrack = self.asset.tracks(withMediaType: AVMediaType.video).first else {
            callback(nil);
            return
        }
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        layerInstruction.trackID = videoTrack.trackID
        
        let instruction = VideoFilterCompositionInstruction(trackID: videoTrack.trackID, filters: self.filters, context: self.context)
        
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration)
        instruction.layerInstructions = [layerInstruction]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.customVideoCompositorClass = VideoFilterCompositor.self
        videoComposition.frameDuration = videoTrack.minFrameDuration
        videoComposition.renderSize = videoTrack.naturalSize
        videoComposition.instructions = [instruction]
        
        let session: AVAssetExportSession = AVAssetExportSession(asset: self.asset, presetName: AVAssetExportPresetHighestQuality)!
        session.videoComposition = videoComposition
        session.outputURL = url
        session.outputFileType = .mp4
        
        session.exportAsynchronously(){
            DispatchQueue.main.async{
                callback(url)
            }
        }
    }
}
