//
//  ViewController.swift
//  barcode_test
//
//  Created by Mariyam on 26.03.18.
//  Copyright © 2018 Mariyam. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ScannerViewController: UIViewController {
    fileprivate let supportedBarcodes = [AVMetadataObject.ObjectType.upce,
                                         AVMetadataObject.ObjectType.code39,
                                         AVMetadataObject.ObjectType.code39Mod43,
                                         AVMetadataObject.ObjectType.code93,
                                         AVMetadataObject.ObjectType.code128,
                                         AVMetadataObject.ObjectType.ean8,
                                         AVMetadataObject.ObjectType.ean13,
                                         AVMetadataObject.ObjectType.pdf417,
                                         AVMetadataObject.ObjectType.itf14,
                                         AVMetadataObject.ObjectType.interleaved2of5]
    

    @IBOutlet weak var scannerView: ScannerView!
    @IBOutlet weak var visionLabel: UILabel!
    @IBOutlet weak var foundationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let session = AVCaptureSession()
        scannerView.session = session
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("No capture device")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("No video input")
            return
        }
        
        session.addInput(videoInput)
        
        let videoOut = AVCaptureVideoDataOutput()
        let metaOut = AVCaptureMetadataOutput()
        let queue = DispatchQueue(label: "home.my.barcode_test.videoOut")
        
        session.beginConfiguration()
        
        session.addOutput(videoOut)
        session.addOutput(metaOut)
        
        videoOut.setSampleBufferDelegate(self, queue: queue)
        metaOut.setMetadataObjectsDelegate(self, queue: queue)
        metaOut.metadataObjectTypes = supportedBarcodes
        
        session.commitConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let session = scannerView.session, !session.isRunning {
            session.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let session = scannerView.session, session.isRunning {
            session.stopRunning()
        }
        
    }
}

// barcode recognition using vision framework
extension ScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: { request, error in
            self.showResults(results: request.results)
        })
        
        let handler = VNImageRequestHandler(cvPixelBuffer: CMSampleBufferGetImageBuffer(sampleBuffer)!, options: [.properties : ""])
        
        guard let _ = try? handler.perform([barcodeRequest]) else {
            return print("Could not perform barcode-request!")
        }
    }
    
    private func showResults(results: [Any]?) {
        
        guard let results = results else {
            return print("No results found.")
        }
        
        for result in results {
            if let barcodeObservation = result as? VNBarcodeObservation,
                let payload = barcodeObservation.payloadStringValue {
                DispatchQueue.main.async {
                    self.visionLabel.text = "Vision: \(payload)"
                }
            }
        }
    }
}

// barcode using avFoundation
extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects {
            let readableObject = metadata as! AVMetadataMachineReadableCodeObject
            let code = readableObject.stringValue
            
            
            self.dismiss(animated: true, completion: nil)
            foundationLabel.text = "AVFoundation: \(code!)"
        }
    }
}
