//
//  ScannerView.swift
//  barcode_test
//
//  Created by Mariyam on 26.03.18.
//  Copyright © 2018 Mariyam. All rights reserved.
//

import AVKit

class ScannerView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get { return videoPreviewLayer.session }
        set { videoPreviewLayer.session = newValue }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
