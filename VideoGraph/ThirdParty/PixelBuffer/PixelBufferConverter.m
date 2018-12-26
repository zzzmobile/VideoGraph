//
//  PixelBufferConverter.m
//  VideoGraph
//
//  Created by Admin on 18/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

#import "PixelBufferConverter.h"

@implementation PixelBufferConverter

+ (CVPixelBufferRef) pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);
    // CVReturn status = CVPixelBufferPoolCreatePixelBuffer(NULL, adaptor.pixelBufferPool, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

+ (NSDictionary *) getAdapterDictionary{
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    return sourcePixelBufferAttributesDictionary;
}

+ (NSDictionary *) getAudioDictionary{
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    
    
    NSDictionary* audioOutputSettings = nil;
    audioOutputSettings = [ NSDictionary dictionaryWithObjectsAndKeys:
                           [ NSNumber numberWithInt: kAudioFormatMPEG4AAC ], AVFormatIDKey,
                           //[ NSNumber numberWithInt: 16 ], AVEncoderBitDepthHintKey,
                           [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
                           [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
                           [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
                           nil ];
    //    NSDictionary* audioOutputSettings = nil;
    //        audioOutputSettings = [ NSDictionary dictionaryWithObjectsAndKeys:
    //                               [ NSNumber numberWithInt: kAudioFormatMPEG4AAC_HE_V2 ], AVFormatIDKey,
    //                               [ NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
    //                               [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
    //                               nil ];
    
    return audioOutputSettings;
}

@end
