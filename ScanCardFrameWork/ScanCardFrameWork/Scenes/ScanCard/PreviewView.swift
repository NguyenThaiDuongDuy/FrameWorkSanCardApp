//
//  PreviewView.swift
//  
//
//  Created by admin on 15/04/2021.
//

import Foundation
import UIKit
import AVFoundation

class PreviewView: UIView {

    lazy var scanAreaShapeLayer: CAShapeLayer = {
        let scanAreaLayer = CAShapeLayer()
        let largeRectanglePath = UIBezierPath(roundedRect: CGRect(x: bounds.origin.x,
                                                                  y: bounds.origin.y,
                                                                  width: bounds.width,
                                                                  height: bounds.height),
                                              cornerRadius: 0)

        let smallRectanglePath = UIBezierPath(roundedRect: CGRect(x: bounds.width / 2 - 150,
                                                                  y: bounds.height / 2 - 100,
                                                                  width: 300,
                                                                  height: 200),
                                              cornerRadius: 20)
        largeRectanglePath.append(smallRectanglePath)
        largeRectanglePath.usesEvenOddFillRule = true
        scanAreaLayer.path = largeRectanglePath.cgPath
        scanAreaLayer.fillRule = .evenOdd
        scanAreaLayer.fillColor = UIColor.darkGray.withAlphaComponent(0.75).cgColor
        scanAreaLayer.opacity = 0.5
        let arrowLayer = CALayer()
        let arrowImage = UIImage(named: "backward", in: Bundle(for: type(of: self)), with: .none)?.cgImage
        arrowLayer.frame = CGRect(x: bounds.width / 2 - 140,
                                  y: bounds.height / 2 - 12,
                                  width: 24,
                                  height: 24)
        arrowLayer.contents = arrowImage
        scanAreaLayer.addSublayer(arrowLayer)
        return scanAreaLayer
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.insertSublayer(scanAreaShapeLayer, at: 1)
    }

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        if let avCaptureVideoPreviewLayer: AVCaptureVideoPreviewLayer = layer as? AVCaptureVideoPreviewLayer {
            return avCaptureVideoPreviewLayer } else {
            return AVCaptureVideoPreviewLayer()
        }
    }
}
