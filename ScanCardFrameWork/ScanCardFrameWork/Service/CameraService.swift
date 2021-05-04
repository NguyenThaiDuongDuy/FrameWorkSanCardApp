//
//  CameraService.swift
//  ScanCard
//
//  Created by admin on 14/04/2021.
//

import AVFoundation
import UIKit
class CameraService {

    let presentViewController: ScanCardViewController
    static let videoProcessQueue = "Handle receive videoFrame"

    lazy var session: AVCaptureSession = {
        let session = AVCaptureSession()
        return session
    }()

    init(viewController: ScanCardViewController) {
        presentViewController = viewController
        setUpSession()
    }

    private func setUpInput() {
        // Scan camera in device
        guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera,
                                                                          .builtInDualCamera,
                                                                          .builtInWideAngleCamera],
                                                            mediaType: .video,
                                                            position: .back).devices.first else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device), session.canAddInput(videoDeviceInput)
        else { return }
        session.addInput(videoDeviceInput)
    }

    private func setUpOutput() {
        let videoOutput = AVCaptureVideoDataOutput()

        videoOutput.videoSettings = [ (kCVPixelBufferPixelFormatTypeKey as NSString):
                                            NSNumber(value: kCVPixelFormatType_32BGRA) ] as [ String: Any ]
        guard session.canAddOutput(videoOutput) else { return }
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(presentViewController,
                                            queue: DispatchQueue(label: CameraService.videoProcessQueue))
        session.addOutput(videoOutput)

        guard let connection = videoOutput.connection(with: .video), connection.isVideoMirroringSupported
        else { return }
        connection.videoOrientation = .portrait
    }

    private func setUpSession() {
        session.beginConfiguration()
        setUpInput()
        setUpOutput()
        session.commitConfiguration()
    }

    func startConnectCamera() {
        if !session.isRunning {
            session.startRunning()
        }
    }

    func stopConnectCamera() {
        session.stopRunning()
    }
}
