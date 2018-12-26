//
//  PixelBufferConverter.h
//  VideoGraph
//
//  Created by Admin on 18/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PixelBufferConverter : NSObject

+ (CVPixelBufferRef) pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size;
+ (NSDictionary *) getAdapterDictionary;
+ (NSDictionary *) getAudioDictionary;

@end
