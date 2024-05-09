//
//  Analyzer.swift
//  LiftingApp
//
//  Created by Kevin Bates on 4/24/24.
//

import Foundation
import CoreML
import Vision

class VideoAnalyzer {
    
    private var outputURL: URL
    private var writer: VideoCreator

    init(outputURL: URL) {
        self.outputURL = outputURL
        self.writer = VideoCreator(url: outputURL)
    }

    func processObservation(_ observation: VNHumanBodyPoseObservation, forFrame frame: CGImage, frameNum: Int) {
        // Retrieve all torso points.
        guard let recognizedPoints = try? observation.recognizedPoints(.torso) else { 
            
            return }
        
        // Torso joint names in a clockwise ordering.
        let torsoJointNames: [VNHumanBodyPoseObservation.JointName] = [
            .neck,
            .rightShoulder,
            .rightHip,
            .root,
            .leftHip,
            .leftShoulder
        ]
        
        // Retrieve the CGPoints containing the normalized X and Y coordinates.
        let imagePoints: [CGPoint] = torsoJointNames.compactMap {
            guard let point = recognizedPoints[$0], point.confidence > 0 else { return nil }
            
            // Translate the point from normalized-coordinates to image coordinates.
            return VNImagePointForNormalizedPoint(point.location,
                                                  Int(frame.width),
                                                  Int(frame.height))
        }
        
        var processedFrame = UIImage(cgImage: frame)
        for point in imagePoints {
            print("X: \(point.x), Y: \(point.y)")
            processedFrame = OpenCVWrapper.addDot(processedFrame, Int32(point.x), Int32(processedFrame.size.height) - Int32(point.y))
        }
        writer.write(image: processedFrame, frameNum: frameNum) { success in
            if !success {
                print("ERRORRRR")
            }
        } numWritten: { frames in
            
        }
    }

    func analyze(frame: CGImage, frameNum: Int) {
        
        let requestHandler = VNImageRequestHandler(cgImage: frame)
        
        // Create a new request to recognize a human body pose.
        let request = VNDetectHumanBodyPoseRequest(completionHandler: { [weak self] request, error in
            self?.bodyPoseHandler(request: request, error: error, forFrame: frame, frameNum: frameNum)
        })
        
        do {
            // Perform the body pose-detection request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request: \(error).")
        }
         
    }

    func bodyPoseHandler(request: VNRequest, error: Error?, forFrame frame: CGImage, frameNum: Int) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else {
            print("error converting results to correct type")
            return
        }
        observations.forEach { processObservation($0, forFrame: frame, frameNum: frameNum) }
    }

    func closeWriter() {
        writer.close()
    }

    
}

class Frame {
    var frameNum: Int
    var frameImg: UIImage
    
    init(frameNum: Int, frameImg: UIImage) {
        self.frameNum = frameNum
        self.frameImg = frameImg
    }
}
