//
//  CameraController.swift
//  AVCOCV-OSX
//
//  Created by buza on 4/21/18.
//  Copyright © 2018 BuzaMoto. All rights reserved.
//

import Cocoa
import AVFoundation
import MetalKit

let AV_CAPTURE_PRESET : AVCaptureSession.Preset = .hd1280x720

class CameraController: NSObject {
    
    @IBOutlet weak var previewLayer             : NSView!
    @IBOutlet weak var metalView                : MTKView!
    
    private let session                         = AVCaptureSession()
    private var videoDeviceInput                : AVCaptureDeviceInput!
    private var videoDevice                     : AVCaptureDevice?
    var layer                                   : AVCaptureVideoPreviewLayer?

    override func awakeFromNib() {
        self.configureSession()
        metalView.device = MTLCreateSystemDefaultDevice();
        OpenCVBridge.shared()?.setMetalView(metalView)
    }

    fileprivate func configureSession() {
        previewLayer.wantsLayer = true
        layer = AVCaptureVideoPreviewLayer(session: session)
        layer!.frame = previewLayer.bounds;
        previewLayer.layer?.addSublayer(layer!)
        
        session.beginConfiguration()

        session.sessionPreset = AV_CAPTURE_PRESET
        addVideoInput()
        addVideoOutput()

        session.commitConfiguration()
        
        session.startRunning()
    }
    
    fileprivate func addVideoOutput() {
        session.beginConfiguration()

        let outputData = AVCaptureVideoDataOutput()

        outputData.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferMetalCompatibilityKey as AnyHashable : true
            ] as! [String : Any]

        outputData.setSampleBufferDelegate(self, queue: DispatchQueue.main)
 
        guard session.canAddOutput(outputData) else {
            print("[CameraController]: Not allowed to add device capture output")
            return
        }
        
        session.addOutput(outputData)
        session.commitConfiguration()
    }

    fileprivate func addVideoInput() {
        
        let videoDevice = AVCaptureDevice.default(for: .video)
        videoDevice?.linkedDevices
        //let linkedDevices = AVCaptureDevice.linkedDevices
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice!)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                print("[CameraController]: Not allowed to add camera input.")
                return
            }
        } catch {
            print("[CameraController]: Failed to create video device input: \(error)")
            return
        }
    }
}


extension CameraController : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        OpenCVBridge.shared()?.update(withSampleBuffer: imageBuffer)
    }
}

