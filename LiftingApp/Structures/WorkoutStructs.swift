//
//  test.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/9/24.
//

import Foundation
import SwiftUI

class ActiveWorkoutDisplayContainer: ObservableObject, Codable {
    static let shared = ActiveWorkoutDisplayContainer()
    
    @Published var display: ActiveWorkoutDisplay?

    init(display: ActiveWorkoutDisplay? = nil) {
        self.display = display
    }

    enum CodingKeys: String, CodingKey {
        case display
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        display = try container.decodeIfPresent(ActiveWorkoutDisplay.self, forKey: .display)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(display, forKey: .display)
    }
}

class ActiveWorkoutDisplay: Identifiable, ObservableObject, Codable {
    let id: UUID
    
    @Published var startTime: Date
    @Published var workoutName: String
    @Published var workoutID: UUID
    @Published var exercises: [ActiveExerciseSetDisplay] = []
    @Published var notes: String
    @Published var previousNotes: String
    
    init(startTime: Date, workoutName: String, workoutID: UUID, notes: String = "", previousNotes: String = "") {
        self.id = UUID()
        self.startTime = startTime
        self.workoutName = workoutName
        self.workoutID = workoutID
        self.notes = notes
        self.previousNotes = previousNotes
    }
    
    // Coding keys to map the properties to the keys in JSON
    enum CodingKeys: String, CodingKey {
        case id
        case startTime
        case workoutName
        case workoutID
        case exercises
        case notes
        case previousNotes
    }

    // Decodable conformance
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        startTime = try container.decode(Date.self, forKey: .startTime)
        workoutName = try container.decode(String.self, forKey: .workoutName)
        workoutID = try container.decode(UUID.self, forKey: .workoutID)
        exercises = try container.decode([ActiveExerciseSetDisplay].self, forKey: .exercises)
        notes = try container.decode(String.self, forKey: .notes)
        previousNotes = try container.decode(String.self, forKey: .previousNotes)
    }

    // Encodable conformance
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(workoutName, forKey: .workoutName)
        try container.encode(workoutID, forKey: .workoutID)
        try container.encode(exercises, forKey: .exercises)
        try container.encode(notes, forKey: .notes)
        try container.encode(previousNotes, forKey: .previousNotes)
    }
}

class ActiveExerciseSetDisplay: Identifiable, ObservableObject, Codable {
    let id: UUID
    
    @Published var exercise: Exercise
    @Published var intensityForm: IntensityType
    @Published var sets: [ActiveSetDisplay] = []
    @Published var inLBs: Bool
    @Published var restTimeSeconds: Int
    
    init(exercise: Exercise, intensityForm: IntensityType, inLBs: Bool, restTimeSeconds: Int) {
        self.id = UUID()
        self.exercise = exercise
        self.intensityForm = intensityForm
        self.inLBs = inLBs
        self.restTimeSeconds = restTimeSeconds
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case exercise
        case intensityForm
        case sets
        case inLBs
        case restTimeSeconds
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        exercise = try container.decode(Exercise.self, forKey: .exercise)
        intensityForm = try container.decode(IntensityType.self, forKey: .intensityForm)
        sets = try container.decode([ActiveSetDisplay].self, forKey: .sets)
        inLBs = try container.decode(Bool.self, forKey: .inLBs)
        restTimeSeconds = try container.decode(Int.self, forKey: .restTimeSeconds)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(exercise, forKey: .exercise)
        try container.encode(intensityForm, forKey: .intensityForm)
        try container.encode(sets, forKey: .sets)
        try container.encode(inLBs, forKey: .inLBs)
        try container.encode(restTimeSeconds, forKey: .restTimeSeconds)
    }
}

class ActiveSetDisplay: Identifiable, ObservableObject, Codable {
    let id: UUID
    
    @Published var targetReps: String
    @Published var intensity: Float
    @Published var achievedReps: Double?
    @Published var weight: Double?
    @Published var completed: Bool
    
    init(targetReps: String, intensity: Float, achievedReps: Double? = nil, weight: Double? = nil) {
        self.id = UUID()
        self.targetReps = targetReps
        self.intensity = intensity
        self.achievedReps = achievedReps
        self.weight = weight
        self.completed = false
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case targetReps
        case intensity
        case achievedReps
        case weight
        case completed
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        targetReps = try container.decode(String.self, forKey: .targetReps)
        intensity = try container.decode(Float.self, forKey: .intensity)
        achievedReps = try container.decodeIfPresent(Double.self, forKey: .achievedReps)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        completed = try container.decode(Bool.self, forKey: .completed)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(targetReps, forKey: .targetReps)
        try container.encode(intensity, forKey: .intensity)
        try container.encodeIfPresent(achievedReps, forKey: .achievedReps)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encode(completed, forKey: .completed)
    }
}

public struct Exercise: Identifiable, Codable, Equatable {
    public var id: UUID
    
    let name: String
    let desc: String
    let primaryMusclesWorked: [Muscles]
    let secondaryMusclesWorked: [Muscles]
    
    init(id: UUID = UUID(), name: String = "default", desc: String = "", primaryMusclesWorked: [Muscles] = [], secondaryMusclesWorked: [Muscles] = []) {
        self.id = id
        self.name = name
        self.desc = desc
        self.primaryMusclesWorked = primaryMusclesWorked
        self.secondaryMusclesWorked = secondaryMusclesWorked
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case desc
        case primaryMusclesWorked
        case secondaryMusclesWorked
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        desc = try container.decode(String.self, forKey: .desc)
        primaryMusclesWorked = try container.decode([Muscles].self, forKey: .primaryMusclesWorked)
        secondaryMusclesWorked = try container.decode([Muscles].self, forKey: .secondaryMusclesWorked)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(desc, forKey: .desc)
        try container.encode(primaryMusclesWorked, forKey: .primaryMusclesWorked)
        try container.encode(secondaryMusclesWorked, forKey: .secondaryMusclesWorked)
    }
}

public enum Muscles: String, Codable {
    case quad = "Quad"
    case hamstring = "Hamstring"
    case calf = "Calf"
    case chest = "Chest"
    case tricep = "Tricep"
    case shoulder = "Shoulder"
    case back = "Back"
    case bicep = "Bicep"
    case frontdeltoid = "Front Deltoid"
    case abdominal = "Abdominal"
    case reardeltoid = "Reat Deltoid"
    case trapezius = "Trap"
    case rotatorcuff = "Rotator Cuff"
    case forearmflexor = "Forearm Flexor"
    case lateraldeltoid = "Lateral Deltoid"
    case lat = "Lat"
    case glute = "Glute"
    case lowback = "Lower Back"
    case adductor = "Adductor"
    case abductor = "Abductor"
    case forearmextensor = "Forearm Extensor"
    case oblique = "Oblique"
}



enum IntensityType: Int16, Codable {
    case RPE = 1
    case PercentOfMax = 2
    case None = 3
}
