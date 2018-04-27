/*
 *  OpenCVProcessor.h
 *
 *  Created by buza on 10/02/08.
 *
 *  Brought to you by buzamoto. http://buzamoto.com
 */

/*
 * This class holds the OpenCV examples.
 * 
 * In order to implement your own, just follow the simple 'passThrough'
 * example. All that CVOCV expects you to do in your function is to
 * return a newly allocated image in RGB format. The renderer will 
 * deallocate this image when necessary. All other resources you allocate
 * however, should be released on your own.
 *
 */

#import <opencv/cv.h>
#import <opencv2/video/tracking.hpp>
#import <Cocoa/Cocoa.h>

@interface OpenCVProcessor : NSObject 

//Passthrough operation.
+ (IplImage *) passThrough:(IplImage *)frame;

//Simple image processing.
+ (IplImage *) cannyTest:(IplImage *)frame;
+ (IplImage *) erode:(IplImage *)frame;
+ (IplImage *) dilate:(IplImage *)frame;
+ (IplImage *) open:(IplImage *)frame;
+ (IplImage *) close:(IplImage *)frame;
+ (IplImage *) adaptiveThresh:(IplImage *)frame;
+ (IplImage *) noiseFilter:(IplImage *)frame;
+ (IplImage *) houghLinesProbabilistic:(IplImage *)frame;
+ (IplImage *) houghLinesStandard:(IplImage *)frame;
+ (IplImage *) houghCircles:(IplImage *)frame;
+ (IplImage *) opticalFlowPyrLK:(IplImage *)frame;

@end
