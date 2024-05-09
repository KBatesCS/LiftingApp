//
//  TestAnalyzer.swift
//  LiftingApp
//
//  Created by Kevin Bates on 5/8/24.
//
import Foundation
import CoreML
import Vision

class TestAnalyzer {
    func analyze(frame: CGImage) -> [[(CGPoint, VNHumanBodyPoseObservation.JointName)]]? {
        let requestHandler = VNImageRequestHandler(cgImage: frame)
        
        var bodyPoints = [[(CGPoint, VNHumanBodyPoseObservation.JointName)]]()
        
        // Create a new request to recognize a human body pose.
        let request = VNDetectHumanBodyPoseRequest(completionHandler: { request, error in
            guard let observations = request.results as? [VNHumanBodyPoseObservation] else {
                print("Error converting results to correct type")
                return
            }
            
            var frameBodyPoints = [[(CGPoint, VNHumanBodyPoseObservation.JointName)]]()
            for observation in observations {
                if let points = self.processObservation(observation, forFrame: frame) {
                    frameBodyPoints.append(points)
                }
            }
            bodyPoints.append(contentsOf: frameBodyPoints)
        })
        
        do {
            // Perform the body pose-detection request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request: \(error).")
            return nil
        }
        
        return bodyPoints.isEmpty ? nil : bodyPoints
    }

    
    func processObservation(_ observation: VNHumanBodyPoseObservation, forFrame frame: CGImage) -> [(CGPoint, VNHumanBodyPoseObservation.JointName)]? {
        // Retrieve all torso points.
        guard let recognizedPoints = try? observation.recognizedPoints(.torso) else {
            return nil
        }
        
        // Torso joint names in a clockwise ordering.
        let torsoJointNames: [VNHumanBodyPoseObservation.JointName] = [
            .neck,
            .rightShoulder,
            .rightHip,
            .root,
            .leftHip,
            .leftShoulder
        ]
        
        // Retrieve the CGPoints containing the normalized X and Y coordinates along with the joint names.
        let imagePoints: [(CGPoint, VNHumanBodyPoseObservation.JointName)] = torsoJointNames.compactMap {
            guard let point = recognizedPoints[$0], point.confidence > 0 else { return nil }
            
            // Translate the point from normalized-coordinates to image coordinates.
            let imagePoint = VNImagePointForNormalizedPoint(point.location, Int(frame.width), Int(frame.height))
            
            // Return tuple with point and joint name
            return (imagePoint, $0)
        }
        
        return imagePoints
    }
}
