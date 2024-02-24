//
//  test.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/9/24.
//

import Foundation
import SwiftUI

class Routine: Identifiable, Codable, ObservableObject {
    @Published var id: UUID
    @Published var ownerID: String
    @Published var name: String
    @Published var workouts: [Workout]
    
    init(id: UUID = UUID(), ownerID: String = "", name: String = "default", workouts: [Workout] = [Workout]()) {
        self.id = id
        self.name = name
        self.workouts = []
        self.ownerID = ownerID
    }
    
    enum CodingKeys: CodingKey {
        case id
        case ownerID
        case name
        case workouts
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(UUID.self, forKey: .id)
        workouts = try container.decode([Workout].self, forKey: .workouts)
        ownerID = try container.decode(String.self, forKey: .ownerID)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
        try container.encode(workouts, forKey: .workouts)
        try container.encode(ownerID, forKey: .ownerID)
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func addWorkout(newWorkout: Workout) {
        self.workouts.append(newWorkout)
    }
    
    
    func createWorkout(name: String) -> Workout {
        let newWorkout: Workout = Workout(name: name)
        self.addWorkout(newWorkout: newWorkout)
        return newWorkout
    }
    
    
    func getLatestWorkout() -> Workout? {
        return self.workouts.last ?? nil
    }
    
    
    func removeWorkout(atPos: Int) {
        workouts.remove(at: atPos)
    }
    
    func save() {
        localSave()
        SQLSave()
    }
    
    func localSave() {
        //saves this info and all the info of the workouts if changed.
    }
    
    func SQLSave() {
        
    }
}

class Workout: Identifiable, Codable, ObservableObject {
    @Published var id: UUID
    
    @Published var name: String
    @Published var exercises: [ExerciseSet]
    @Published var notes: String
    
    init(id: UUID = UUID(), name: String = "default", exercises: [ExerciseSet] = [ExerciseSet]()) {
        self.id = id
        self.name = name
        self.notes = ""
        self.exercises = exercises
    }
    
    enum CodingKeys: CodingKey {
        case id
        case notes
        case name
        case exercises
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(UUID.self, forKey: .id)
        exercises = try container.decode([ExerciseSet].self, forKey: .exercises)
        notes = try container.decode(String.self, forKey: .notes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
        try container.encode(exercises, forKey: .exercises)
        try container.encode(notes, forKey: .notes)
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func addExercise(newExercise: ExerciseSet) {
        exercises.append(newExercise)
    }
    
    func addExercise(newExercise: Exercise) {
        exercises.append(ExerciseSet(exerciseInfo: newExercise))
    }
    
    func removeExercise(atPos: Int) {
        exercises.remove(at: atPos)
    }
    
    func save() {
        localSave()
        SQLSave()
    }
    
    func localSave() {
        //saves this info, and the info of all the exersizeSets if changed
    }
    
    func SQLSave() {
        
    }
}

class ExerciseSet: Identifiable, Codable {
    var id: UUID
    
    var name: String
    var exerciseInfo: Exercise
    var repList: [Int]
    var intensityForm: IntensityType
    var intensityList: [Int]
    var restLengths: [Int] //in seconds
    var notes: String
    
    init(id: UUID = UUID(), exerciseInfo: Exercise,
         intensityForm: IntensityType = IntensityType.None) {
        self.id = id
        self.name = exerciseInfo.name
        self.notes = ""
        
        self.exerciseInfo = exerciseInfo
        self.intensityForm = intensityForm
        self.intensityList = []
        self.repList = [12,12,12]
        self.restLengths = [90,90,90]
        self.setIntensityListToDefaults()
        
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func changeIntensityForm(newIntensityForm: IntensityType) {
        if self.intensityForm == newIntensityForm {
            return
        }
        
        self.intensityForm = newIntensityForm
        self.setIntensityListToDefaults()
    }
    
    func setIntensityListToDefaults() {
        if self.intensityForm == IntensityType.PercentOfMax {
            self.intensityList = Array(repeating: 75, count: repList.count)
        } else if self.intensityForm == IntensityType.RPE {
            self.intensityList = Array(repeating: 8, count: repList.count)
        } else {
            self.intensityList = []
        }
    }
    
    func changeIntensity(intensityPos: Int = -1, newIntensity: Int) {
        if (intensityPos == -1) {
            for i in intensityList.indices {
                intensityList[i] = newIntensity
            }
        } else if (intensityPos >= -1 && intensityPos < intensityList.count) {
            intensityList[intensityPos] = newIntensity
        }
    }
    
    func addSet() {
        repList.append(repList.last ?? 12)
        restLengths.append(restLengths.last ?? 90)
        intensityList.append(intensityList.last ?? 0)
    }
    
    func removeSet(atPos: Int = -1) {
        if repList.count <= 0 {
            return
        }
        
        if atPos == -1 {
            repList.removeLast()
            intensityList.removeLast()
            restLengths.removeLast()
        } else if atPos > 0 && atPos < repList.count {
            repList.remove(at: atPos)
            intensityList.remove(at: atPos)
            restLengths.remove(at: atPos)
        }
    }
}

struct Exercise: Identifiable, Codable {
    var id: UUID
    
    let name: String
    let musclesWorked: [Muscles]
    
    init(id: UUID = UUID(), name: String = "default", musclesWorked: [Muscles] = []) {
        self.id = id
        self.name = name
        self.musclesWorked = musclesWorked
    }
}

enum Muscles: Codable {
    case quad, hamstring, calf,
        chest, tricep, shoulder,
        back, bicep
}

enum IntensityType: Codable {
    case RPE, PercentOfMax, None
}
