//
//  OpenCVBridge.h
//  AVCOCV-OSX
//
//  Created by buza on 4/23/18.
//  Copyright © 2018 BuzaMoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <MetalKit/MetalKit.h>

@interface OpenCVBridge : NSObject

+ (OpenCVBridge*) sharedBridge;
- (void) setMetalView:(MTKView*) view;
- (void) updateWithSampleBuffer:(CVImageBufferRef) videoFrame;

@end
