//
//  test.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/9/24.
//

import Foundation
import SwiftUI

class ActiveWorkoutDisplayContainer: ObservableObject {
    @Published var display: ActiveWorkoutDisplay? = nil
}

class ActiveWorkoutDisplay: Identifiable, ObservableObject {
    let id = UUID()
    
    @Published var startTime: Date
    @Published var workoutName: String
    @Published var workoutID: UUID
    @Published var exercises: [ActiveExerciseSetDisplay] = []
    @Published var notes: String = ""
    @Published var previousNotes: String = ""
    
    init(startTime: Date, workoutName: String, workoutID: UUID, notes: String = "", previousNotes: String = "") {
        self.startTime = startTime
        self.workoutName = workoutName
        self.workoutID = workoutID
        self.notes = notes
        self.previousNotes = previousNotes
    }
   
}

class ActiveExerciseSetDisplay: Identifiable, ObservableObject {
    let id = UUID()
    @Published var exercise: Exercise
    @Published var intensityForm: IntensityType
    @Published var sets: [ActiveSetDisplay] = []
    @Published var inLBs: Bool
    
    init(exercise: Exercise, intensityForm: IntensityType, inLBs: Bool) {
        self.exercise = exercise
        self.intensityForm = intensityForm
        self.inLBs = inLBs
    }
}

class ActiveSetDisplay: Identifiable, ObservableObject {
    let id = UUID()
    @Published var targetReps: String
    @Published var intensity: Float
    @Published var achievedReps: Double?
    @Published var weight: Double?
    @Published var completed: Bool = false
    
    
    init(targetReps: String, intensity: Float, achievedReps: Double? = nil, weight: Double? = nil) {
        self.targetReps = targetReps
        self.intensity = intensity
        self.achievedReps = achievedReps
        self.weight = weight
    }
}

struct Exercise: Identifiable, Codable, Equatable {
    var id: UUID
    
    let name: String
    let primaryMusclesWorked: [Muscles]
    let secondaryMusclesWorked: [Muscles]
    
    init(id: UUID = UUID(), name: String = "default", primaryMusclesWorked: [Muscles] = [], secondaryMusclesWorked: [Muscles] = []) {
        self.id = id
        self.name = name
        self.primaryMusclesWorked = primaryMusclesWorked
        self.secondaryMusclesWorked = secondaryMusclesWorked
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case primaryMusclesWorked
        case secondaryMusclesWorked
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        primaryMusclesWorked = try container.decode([Muscles].self, forKey: .primaryMusclesWorked)
        secondaryMusclesWorked = try container.decode([Muscles].self, forKey: .secondaryMusclesWorked)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(primaryMusclesWorked, forKey: .primaryMusclesWorked)
        try container.encode(secondaryMusclesWorked, forKey: .secondaryMusclesWorked)
    }
}

enum Muscles: Codable {
    case quad
    case hamstring
    case calf
    case chest
    case tricep
    case shoulder
    case back
    case bicep
    case frontdeltoid
    case abdominal
    case reardeltoid
    case trapezius
    case rotatorcuff
    case forearmflexor
    case lateraldeltoid
    case lat
    case glute
    case lowback
    case adductor
    case forearmextensor
    case oblique
}



enum IntensityType: Int16, Codable {
    case RPE = 1
    case PercentOfMax = 2
    case None = 3
}
