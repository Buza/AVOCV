#  AVOCV: An AVFoundation-based OpenCV experimentation environment.

AVOCV was built in order to create an extremely simple and
lightweight OpenCV experimentation environment for
OS X 10.13.x. This is a more modern update to CVOCV, a QTKit + OpenGL
version written in 2008 for OSX 10.5.

## Prerequisites
In contrast to CVOCV, which contained precompiled OpenCV binaries, to use AVOCV, you'll
need to install OpenCV on your mac. 
See [this tutorial](https://blogs.wcode.org/2014/10/howto-install-build-and-use-opencv-macosx-10-10/) as an example.

## Usage

At the heart of AVOCV is the delegate method:

public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)

in CameraController.swift. This is a callback procedure that is invoked
by AVFoundation to provide direct access to the pixels coming from 
a video input device. To experiment with the existing examples 
offered by AVOCV, simply uncomment one of the lines in the 
captureOutput method.

For example, the line

IplImage *resultImage = [OpenCVProcessor cannyTest:frameImage];

in captureOutput will create an OpenCV-processed image from the
current input frame, and send the pixels to Metal to be rendered.

For users that would like to implement their own examples, simply
look at OpenCVProcessor.m for examples.

## Contributions
-------------

Contributions in the form of elegant, demonstrative examples are
welcome and encouraged. Contact me if you have something you
think would make a nice addition to this project.

2018 Kyle Buza
buza@buzamoto.com

