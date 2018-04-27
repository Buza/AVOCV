//
//  OpenCVBridge.m
//  AVCOCV-OSX
//
//  Created by buza on 4/23/18.
//  Copyright © 2018 BuzaMoto. All rights reserved.
//

#import <opencv/cv.h>

#import "OpenCVBridge.h"
#import "OpenCVProcessor.h"
#import "AAPLRenderer.h"

@implementation OpenCVBridge
{
    IplImage        *frameImage;
    AAPLRenderer    *_renderer;
}

+ (OpenCVBridge*)sharedBridge {
    static OpenCVBridge *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}

-(id) init {
    frameImage = (IplImage*)malloc(sizeof(IplImage));
    return self;
}

-(void) setMetalView:(MTKView*) view {
    _renderer = [[AAPLRenderer alloc] initWithMetalKitView:view];
     [_renderer mtkView:view drawableSizeWillChange:view.drawableSize];

    if(!_renderer)
    {
        NSLog(@"Renderer failed initialization");
        return;
    }
    
    view.delegate = _renderer;
    [view setNeedsDisplay:true];
}

-(void) updateWithSampleBuffer:(CVImageBufferRef) videoFrame {

    CVPixelBufferLockBaseAddress((CVPixelBufferRef)videoFrame, 0);

    char* baseAddress = (char*)CVPixelBufferGetBaseAddress((CVPixelBufferRef)videoFrame);

    const size_t offset = 64;
    const size_t sz = CVPixelBufferGetDataSize((CVPixelBufferRef)videoFrame);

    //Fill in the OpenCV image struct from the data from CoreVideo.
    frameImage->nSize       = sizeof(IplImage);
    frameImage->ID          = 0;
    frameImage->nChannels   = 4;
    frameImage->depth       = IPL_DEPTH_8U;
    frameImage->dataOrder   = 0;
    frameImage->origin      = 0; //Top left origin.
    frameImage->width       = (int)CVPixelBufferGetWidth((CVPixelBufferRef)videoFrame);
    frameImage->height      = (int)CVPixelBufferGetHeight((CVPixelBufferRef)videoFrame);
    frameImage->roi         = 0; //Region of interest. (struct IplROI).
    frameImage->maskROI     = 0;
    frameImage->imageId     = 0;
    frameImage->tileInfo    = 0;
    frameImage->imageSize   = (int)(sz - offset);
    frameImage->imageData   = baseAddress + offset;
    frameImage->widthStep   = (int)CVPixelBufferGetBytesPerRow((CVPixelBufferRef)videoFrame);
    frameImage->imageDataOrigin = baseAddress + offset;

    //Process the frame, and get the result.
    //IplImage *resultImage = [OpenCVProcessor dilate:frameImage];

    //Another example.
    IplImage *resultImage = [OpenCVProcessor opticalFlowPyrLK:frameImage];
    
    [_renderer updateWithImage:resultImage];

    CVPixelBufferUnlockBaseAddress((CVPixelBufferRef)videoFrame, 0);
}

@end
