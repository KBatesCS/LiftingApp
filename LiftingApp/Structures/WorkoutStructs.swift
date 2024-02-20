//
//  test.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/9/24.
//

import Foundation
import SwiftUI

struct Routine: Identifiable, Codable {
    var id: UUID
    
    var ownerID: String
    var name: String
    var workouts: [workout]
    
    init(id: UUID = UUID(), ownerID: String = "", name: String = "default", workouts: [workout] = []) {
        self.id = id
        self.name = name
        self.workouts = []
        self.ownerID = ownerID
    }
    
    mutating func setName(name: String) {
        self.name = name
    }
    
    mutating func addWorkout(newWorkout: workout) {
        self.workouts.append(newWorkout)
    }
    
    mutating func removeWorkout(atPos: Int) {
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

struct workout: Identifiable, Codable {
    var id: UUID
    
    var name: String
    var exercises: [ExerciseSet]
    
    init(id: UUID = UUID(), name: String = "default", exercises: [ExerciseSet] = []) {
        self.id = id
        self.name = name
        self.exercises = exercises
    }
    
    mutating func setName(name: String) {
        self.name = name
    }
    
    mutating func addExercise(newExercise: ExerciseSet) {
        exercises.append(newExercise)
    }
    
    mutating func addExercise(newExercise: Exercise) {
        exercises.append(ExerciseSet(exerciseInfo: newExercise))
    }
    
    mutating func removeExercise(atPos: Int) {
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

struct ExerciseSet: Identifiable, Codable {
    var id: UUID
    
    var name: String
    var exerciseInfo: Exercise
    var repList: [Int]
    var intensityForm: IntensityType
    var intensityList: [Int]
    var restLengths: [Int] //in seconds
    
    init(id: UUID = UUID(), exerciseInfo: Exercise,
         intensityForm: IntensityType = IntensityType.None) {
        self.id = id
        self.name = exerciseInfo.name
        
        self.exerciseInfo = exerciseInfo
        self.intensityForm = intensityForm
        self.intensityList = []
        self.repList = [12,12,12]
        self.restLengths = [90,90,90]
        self.setIntensityListToDefaults()
    }
    
    mutating func setName(name: String) {
        self.name = name
    }
    
    mutating func changeIntensityForm(newIntensityForm: IntensityType) {
        if self.intensityForm == newIntensityForm {
            return
        }
        
        self.intensityForm = newIntensityForm
        self.setIntensityListToDefaults()
    }
    
    mutating func setIntensityListToDefaults() {
        if self.intensityForm == IntensityType.PercentOfMax {
            self.intensityList = Array(repeating: 75, count: repList.count)
        } else if self.intensityForm == IntensityType.RPE {
            self.intensityList = Array(repeating: 8, count: repList.count)
        } else {
            self.intensityList = []
        }
    }
    
    mutating func changeIntensity(intensityPos: Int = -1, newIntensity: Int) {
        if (intensityPos == -1) {
            for i in intensityList.indices {
                intensityList[i] = newIntensity
            }
        } else if (intensityPos >= -1 && intensityPos < intensityList.count) {
            intensityList[intensityPos] = newIntensity
        }
    }
    
    mutating func addSet() {
        repList.append(repList.last ?? 12)
        restLengths.append(restLengths.last ?? 90)
        intensityList.append(intensityList.last ?? 0)
    }
    
    mutating func removeSet(atPos: Int = -1) {
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
