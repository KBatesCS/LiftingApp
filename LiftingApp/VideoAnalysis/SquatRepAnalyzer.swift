//
//  squatRepAnalyzer.swift
//  LiftingApp
//
//  Created by Kevin Bates on 7/15/24.
//

import Foundation
import AVFoundation
import Vision

struct SquatRepAnalyzer {
    public var repCounter: Int = 0
    
    private var pastPosX = -1
    private var pastPosY = -1
    private var turningPointY = -1
    private var framesGoingDown = 0
    private var framesGoingUp = 0
    
    private var errorFrames = 0
    private var squatState = SquatState.NONE
    
    private let ERROR_LIMIT = 3
    private let HEIGHT_CHANGE_MINIMUM = 50
    
    private let imageHeight: Int
    
    init(imageHeight: Int) {
        self.imageHeight = imageHeight
    }
    
    func getState() -> String {
        if squatState == SquatState.NONE {
            return "Not Started"
        } else if squatState == SquatState.DOWN {
            return "Down"
        } else if squatState == SquatState.UP {
            return "Up"
        }
        
        return "default"
    }
    
    mutating func add(observations: [(CGPoint, VNHumanBodyPoseObservation.JointName)]) {
        var xAvg = 0
        var yAvg = 0
        //second var is the joint, but it's not used.
        for (point, _) in observations {
            xAvg += Int(point.x)
            yAvg += imageHeight - Int(point.y)
        }
        xAvg /= observations.count
        yAvg /= observations.count
        addPos(x: xAvg, y: yAvg)
    }
    
    mutating func addPos(x: Int, y: Int) {
        if pastPosX == -1  || pastPosY == -1 {
            pastPosX = x
            pastPosY = y
            return
        }
        
        if y < pastPosY {
            framesGoingDown += 1
        } else if y > pastPosY {
            framesGoingUp += 1
        }
        
        
        // LOGIC
        if squatState == SquatState.DOWN {
            if y > pastPosY {
                errorFrames += 1
                if errorFrames > ERROR_LIMIT {
                    squatState = SquatState.UP
                    framesGoingDown = 0
                }
            } else {
                errorFrames = 0
            }
            
//            if framesGoingUp >
        } else if squatState == SquatState.UP {
            if y < pastPosY {
                errorFrames += 1
                if errorFrames > ERROR_LIMIT {
                    squatState = SquatState.UP
                    framesGoingDown = 0
                }
            } else {
                errorFrames = 0
            }
        } else if squatState == SquatState.NONE {
            if framesGoingDown >= 5 {
                squatState = SquatState.DOWN
            }
        }
    }
}

enum SquatState {
    case DOWN
    case UP
    case NONE
}
