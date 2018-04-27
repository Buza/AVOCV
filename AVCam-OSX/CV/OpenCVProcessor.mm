/*
 *  OpenCVProcessor.m
 *
 *  Created by buza on 10/02/08.
 *
 *  Brought to you by buzamoto. http://buzamoto.com
 */

#import "OpenCVProcessor.h"
#import "math.h"

@implementation OpenCVProcessor

/*!
 * function passThrough
 * discussion The most trivial example. Does nothing but pass the image through, unmodified.
 * updated 2008-12-23
 */
+ (IplImage *) passThrough:(IplImage *)frame
{
    //First, we need to create our "result" image, that OpenGL will use to display.
    // (The openGL renderer will destroy this when it needs to.)
    IplImage *texImage = cvCreateImage(cvSize(frame->width, frame->height), frame->depth, frame->nChannels);
    //texImage->imageSize = frame->imageSize;
    //Process the image.
    // ...
    
    //Copy the result into our newly allocated image, and pass it on.
    cvCopy(frame, texImage, 0);
    return texImage;
}

/*!
 * function cannyTest
 * discussion Canny edge detection.
 * updated 2008-12-25
 */
+ (IplImage *) cannyTest:(IplImage *)frame
{
    IplImage *texImage = cvCreateImage(cvSize(frame->width, frame->height), frame->depth, frame->nChannels);

    CvSize sz = cvSize(frame->width & -2, frame->height & -2);
    IplImage* timg = cvCloneImage(frame);
    IplImage* gray = cvCreateImage(sz, IPL_DEPTH_8U, 1);
    IplImage* tgray =  cvCreateImage(sz, IPL_DEPTH_8U, 1);
    
    cvSetImageCOI(frame, 1);
    
    cvCopy(frame, tgray, 0);
    cvCanny(tgray, gray, 0, 5, 5);
    
    cvDilate(gray, gray, 0, 1);
    
    cvCvtColor(gray, texImage, CV_GRAY2RGB);
    
    cvReleaseImage(&gray);
    cvReleaseImage(&tgray);
    cvReleaseImage(&timg);
    
    return texImage;
}


/*!
 * function erode
 * discussion Perform image erosion. Erosion computes a local minimum over the area of the kernel.
 * updated 2009-1-22
 */
+ (IplImage *) erode:(IplImage *)frame
{
    IplImage *texImage = cvCreateImage(cvSize(frame->width, frame->height), frame->depth, frame->nChannels);
    cvCopy(frame, texImage, 0);
    
    //Default number of iterations is 1. We'll do a few iterations to make the effect more pronounced.
    cvErode(texImage, texImage, NULL, 12);
    
    return texImage;
}

/*!
 * function dilate
 * discussion Perform image dilation. Dilation computes a local maximum over the area of the kernel. Used to find connected components.
 * updated 2009-1-22
 */
+ (IplImage *) dilate:(IplImage *)frame
{
    IplImage *texImage = cvCreateImage(cvSize(frame->width, frame->height), frame->depth, frame->nChannels);
    cvCopy(frame, texImage, 0);
    
    //Default number of iterations is 1. We'll do a few iterations to make the effect more pronounced.
    cvDilate(texImage, texImage, NULL, 12);
    
    return texImage;
}

/*!
 * function open
 * discussion Perform image opening with a custom kernel.
 * updated 2009-1-22
 */
+ (IplImage *) open:(IplImage *)frame
{
    IplImage *texImage = cvCreateImage(cvSize(frame->width, frame->height), frame->depth, frame->nChannels);
    cvCopy(frame, texImage, 0);
    
    IplConvKernel* openKernel = cvCreateStructuringElementEx(3, 3, 1, 1, CV_SHAPE_RECT, NULL);
    
    //Default number of iterations is 1. We'll do a few iterations to make the effect more pronounced.
    cvMorphologyEx(texImage, texImage, NULL, (IplConvKernel *)openKernel, CV_MOP_OPEN, 9);
    
    return texImage;
}

/*!
 * function close
 * discussion Perform image closing with a custom kernel.
 * updated 2009-1-22
 */
+ (IplImage *) close:(IplImage *)frame
{
    IplImage *texImage = cvCreateImage(cvSize(frame->width, frame->height), frame->depth, frame->nChannels);
    cvCopy(frame, texImage, 0);
    
    IplConvKernel* closeKernel = cvCreateStructuringElementEx(7, 7, 3, 3, CV_SHAPE_RECT, NULL);
    
    //Default number of iterations is 1. We'll do a few iterations to make the effect more pronounced.
    cvMorphologyEx(texImage, texImage, NULL, (IplConvKernel *)closeKernel, CV_MOP_CLOSE, 9);
    
    return texImage;
}

/*!
 * function adaptiveThresh
 * discussion Perform adaptive thresholding.
 * updated 2009-1-22
 */
+ (IplImage *) adaptiveThresh:(IplImage *)frame
{
    IplImage *grayTex = cvCreateImage(cvSize(frame->width, frame->height), frame->depth, 1);
    IplImage *grayTemp = cvCreateImage(cvSize(frame->width, frame->height), frame->depth, 1);
    
    cvCvtColor(frame, grayTex, CV_RGB2GRAY);
    
    int type =  CV_THRESH_BINARY;           //CV_THRESH_BINARY_INV;
    int method = CV_ADAPTIVE_THRESH_MEAN_C; //CV_ADAPTIVE_THRESH_GAUSSIAN_C;
    
    int blockSize = 73;
    double offset = 15;
    
    cvAdaptiveThreshold(grayTex, grayTemp, 255, method, type, blockSize, offset);
    
    IplImage *result = cvCreateImage(cvSize(frame->width, frame->height), frame->depth, frame->nChannels);
    cvCvtColor(grayTemp, result, CV_GRAY2RGB);
    
    cvReleaseImage(&grayTex);
    cvReleaseImage(&grayTemp);
    
    return result;
}

/*!
 * function noiseFilter
 * discussion Remove image noise by performing the down- and up- sampling steps of Gaussian pyramid decomposition.
 * updated 2008-12-25
 */
+ (IplImage *) noiseFilter:(IplImage *)frame
{
    IplImage *texImage = cvCreateImage(cvSize(frame->width, frame->height), frame->depth, frame->nChannels);
    
    IplImage* timg = cvCloneImage(frame);
    IplImage* pyr = cvCreateImage(cvSize(frame->width/2, frame->height/2), frame->depth, frame->nChannels);
    
    cvPyrDown(timg, pyr, 7);
    cvPyrUp(pyr, texImage, 7);
    
    cvReleaseImage(&pyr);
    cvReleaseImage(&timg);
    
    return texImage;
}

/*!
 * function houghLinesProbabilistic
 * discussion Find lines in a binary image using the probabilistic Hough transform example from the OpenCV documentation.
 * updated 2008-12-25
 */
+ (IplImage *) houghLinesProbabilistic:(IplImage *)frame
{
    CvSize sz = cvGetSize(frame);
    
    IplImage* tgray =  cvCreateImage(sz, frame->depth, 1);
    IplImage* dst = cvCreateImage(sz, frame->depth, 1);
    IplImage* color_dst = cvCreateImage(cvSize(frame->width, frame->height), frame->depth, frame->nChannels);
    CvMemStorage* storage = cvCreateMemStorage(0);
    
    cvCvtColor(frame, tgray, CV_RGB2GRAY);
    
    cvCanny(tgray, dst, 50, 200, 3);
    cvCvtColor( dst, color_dst, CV_GRAY2BGR );
    
    CvSeq* lines = cvHoughLines2(dst, storage, CV_HOUGH_PROBABILISTIC, 1, CV_PI/180, 50, 50, 10);
    
    int i;
    for(i = 0; i < lines->total; i++) {
        CvPoint* line = (CvPoint*)cvGetSeqElem(lines,i);
        cvLine( color_dst, line[0], line[1], CV_RGB(255,0,0), 1, CV_AA, 0);
    }
    
    cvReleaseImage(&dst);
    cvReleaseImage(&tgray);
    cvReleaseMemStorage(&storage);
    
    return color_dst;
}

/*!
 * function houghLinesStandard
 * discussion Find lines in a binary image using the Hough transform example from the OpenCV documentation.
 * updated 2008-12-25
 */
+ (IplImage *) houghLinesStandard:(IplImage *)frame
{
    CvSize sz = cvGetSize(frame);
    
    IplImage* tgray =  cvCreateImage(sz, frame->depth, 1);
    IplImage* dst = cvCreateImage(sz, frame->depth, 1);
    IplImage* color_dst = cvCreateImage(cvSize(frame->width, frame->height), frame->depth, frame->nChannels);
    CvMemStorage* storage = cvCreateMemStorage(0);
    
    cvCvtColor(frame, tgray, CV_RGB2GRAY);
    
    cvCanny(tgray, dst, 50, 200, 3);
    cvCvtColor(dst, color_dst, CV_GRAY2BGR);
    CvSeq* lines = cvHoughLines2(dst, storage, CV_HOUGH_STANDARD, 1, CV_PI/180, 100, 0, 0);
    
    int i;
    for(i = 0; i < MIN(lines->total,100); i++) {
        float* line = (float*)cvGetSeqElem(lines,i);
        float rho = line[0];
        float theta = line[1];
        CvPoint pt1, pt2;
        double a = cos(theta), b = sin(theta);
        double x0 = a*rho, y0 = b*rho;
        pt1.x = cvRound(x0 + 1000*(-b));
        pt1.y = cvRound(y0 + 1000*(a));
        pt2.x = cvRound(x0 - 1000*(-b));
        pt2.y = cvRound(y0 - 1000*(a));
        cvLine(color_dst, pt1, pt2, CV_RGB(255,0,0), 1, CV_AA, 0);
    }
    
    cvReleaseImage(&dst);
    cvReleaseImage(&tgray);
    cvReleaseMemStorage(&storage);
    
    return color_dst;
}

/*!
 * function houghCircles
 * discussion Find circles in a binary image using the Hough transform example from the OpenCV documentation.
 * updated 2008-12-25
 */
+ (IplImage *) houghCircles:(IplImage *)frame
{
    IplImage *texImage = cvCreateImage(cvSize(frame->width, frame->height), frame->depth, frame->nChannels);
    
    cvCopy(frame, texImage, 0);
    
    IplImage* gray = cvCreateImage(cvGetSize(frame), frame->depth, 1);
    CvMemStorage* storage = cvCreateMemStorage(0);
    cvCvtColor(frame, gray, CV_BGR2GRAY);
    cvSmooth(gray, gray, CV_GAUSSIAN, 9, 9, 0, 0); // smooth it, otherwise a lot of false circles may be detected
    CvSeq* circles = cvHoughCircles(gray, storage, CV_HOUGH_GRADIENT, 2, gray->height/4, 200, 100, 0, 1000);
    int i;
    for( i = 0; i < circles->total; i++ )
    {
        float* p = (float*)cvGetSeqElem( circles, i );
        cvCircle(texImage, cvPoint(cvRound(p[0]),cvRound(p[1])), 3, CV_RGB(0,255,0), -1, 8, 0);
        cvCircle(texImage, cvPoint(cvRound(p[0]),cvRound(p[1])), cvRound(p[2]), CV_RGB(255,0,0), 3, 8, 0);
    }
    
    cvReleaseImage(&gray);
    cvReleaseMemStorage(&storage);
    
    return texImage;
}

/*!
 * function opticalFlowPyrLK
 * @discussion Optical flow using the iterative Lucas & Kanade Technique in pyramids.
 * @updated 2018-4-27
 */
+ (IplImage *) opticalFlowPyrLK:(IplImage *)frame
{
    static IplImage *prevFrame = 0;
    
    CvSize sz = cvGetSize(frame);
    
    IplImage *grayflow = cvCreateImage(sz, frame->depth, 1);
    IplImage *flow = cvCreateImage(sz, frame->depth, frame->nChannels);
    cvCopy(frame, flow, 0);
    
    if(prevFrame == 0) {
        IplImage *prevFrameAlloc = cvCreateImage(sz, frame->depth, frame->nChannels);
        cvCopy(frame, prevFrameAlloc, 0);
        prevFrame = prevFrameAlloc;
    }
    
    CvSize window = cvSize(4,4);
    
    IplImage *grayCur = cvCreateImage(sz, frame->depth, 1);
    IplImage *grayPrev = cvCreateImage(sz, frame->depth, 1);
    
    cvCvtColor(frame, grayCur, CV_RGB2GRAY);
    cvCvtColor(prevFrame, grayPrev, CV_RGB2GRAY);

    int stepw = 640/10;
    int steph = 360/10;
    int numFeatures = stepw * steph;

    CvPoint2D32f cvsrc[numFeatures];
    CvPoint2D32f cvdst[numFeatures];

    //We don't really need to compute this each time. Should only need do it once.
    int i, j;
    for(i=0; i<steph; i++) {
        for(j=0; j<stepw; j++) {
            cvsrc[i*stepw + j].x = 10 + j * (640*2/stepw);
            cvsrc[i*stepw + j].y = 10 + (360*2/steph) * i;
        }
    }

    char status[numFeatures];
    CvTermCriteria term = cvTermCriteria(CV_TERMCRIT_ITER | CV_TERMCRIT_EPS, 10, 0.8);
    
    cvCalcOpticalFlowPyrLK(grayCur, grayPrev, 0, 0, cvsrc, cvdst, numFeatures, window, 1, status, 0, term, 0);
    
    //Arrow drawing from David Stavens' document "The OpenCV Library: Computing Optical Flow".
    // http://robots.stanford.edu/cs223b05/notes/
    
    for(i = 0; i < numFeatures; i++)
    {
        if (status[i] == 0) continue;
        
        int line_thickness = 1;
        
        CvScalar line_color; line_color = CV_RGB(0,0,255);
        
        CvPoint p,q;
        p.x = (int) cvsrc[i].x;
        p.y = (int) cvsrc[i].y;
        q.x = (int) cvdst[i].x;
        q.y = (int) cvdst[i].y;
        
        double angle; angle = atan2((double) p.y - q.y, (double) p.x - q.x);
        double hypotenuse; hypotenuse = sqrt((p.y - q.y)*(p.y - q.y) + (p.x - q.x)*(p.x - q.x));
        
        q.x = (int) (p.x - 0.5 * hypotenuse * cos(angle));
        q.y = (int) (p.y - 0.5 * hypotenuse * sin(angle));
        
        cvLine(flow, p, q, line_color, line_thickness, CV_AA, 0);
        
        p.x = (int) (q.x + 4.5 * cos(angle + M_PI / 4));
        p.y = (int) (q.y + 4.5 * sin(angle + M_PI / 4));
        cvLine(flow, p, q, line_color, line_thickness, CV_AA, 0);
        p.x = (int) (q.x + 4.5 * cos(angle - M_PI / 4));
        p.y = (int) (q.y + 4.5 * sin(angle - M_PI / 4));
        cvLine(flow, p, q, line_color, line_thickness, CV_AA, 0);
    }
    
    cvReleaseImage(&grayCur);
    cvReleaseImage(&grayPrev);
    cvReleaseImage(&prevFrame);
    cvReleaseImage(&grayflow);
    
    IplImage *prevFrameAlloc = cvCreateImage(sz, frame->depth, frame->nChannels);
    cvCopy(frame, prevFrameAlloc, 0);
    prevFrame = prevFrameAlloc;
    
    return flow;
}


@end
