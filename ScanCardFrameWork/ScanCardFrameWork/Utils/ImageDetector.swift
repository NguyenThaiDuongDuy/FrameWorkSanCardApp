//
//  Detetor.swift
//  ScanCard
//
//  Created by admin on 26/04/2021.
//
import Vision

enum ImageDetector {

    static func detectCard(sampleBuffer: CMSampleBuffer,
                           completion: @escaping (Result<VNRectangleObservation, Error>) -> Void) {
        let request = VNDetectRectanglesRequest { (request, error) in
            if let error = error {
                completion(.failure(error))
            }
            guard let rectanglesDetect = request.results as?
                    [VNRectangleObservation] else { return }
            guard let rectangleDetect = rectanglesDetect.first else { return }
            completion(.success(rectangleDetect))
        }
        request.minimumAspectRatio = VNAspectRatio(1.3)
        request.maximumAspectRatio = VNAspectRatio(1.6)
        request.minimumSize = Float(0.5)
        request.maximumObservations = 1

        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])

        do {
            try requestHandler.perform([request])
        } catch let error {
            Logger.log(error.localizedDescription)
        }
    }

    static func detectText(cgImage: CGImage, completion: @escaping ((Result<[String], Error>)) -> Void) {
        let request = VNRecognizeTextRequest { (request, error) in

            if let error = error {
                completion(.failure(error))
            }

            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            completion(.success(recognizedStrings))
        }
        request.recognitionLevel = .accurate
        request.minimumTextHeight = 1 / 20
        let requestTextHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try requestTextHandler.perform([request])
        } catch let error {
            Logger.log(error.localizedDescription)
        }
    }
}
