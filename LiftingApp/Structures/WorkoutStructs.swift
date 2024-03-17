//
//  test.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/9/24.
//

import Foundation
import SwiftUI

class RoutineList: Identifiable, Codable, ObservableObject {
    @Published var id: UUID
    @Published var routines: [Routine] = []
    @Published var user: String
    
    init(id: UUID = UUID(), user: String) {
        self.id = id
        self.user = user
    }
    
    enum CodingKeys: CodingKey {
        case routines
        case id
        case user
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routines = try container.decode([Routine].self, forKey: .routines)
        id = try container.decode(UUID.self, forKey: .id)
        user = try container.decode(String.self, forKey: .user)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(routines, forKey: .routines)
        try container.encode(id, forKey: .id)
        try container.encode(user, forKey: .user)
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: user)
        }
    }
    
    func refreshAndSave() {
        save()
        objectWillChange.send()
    }
}

class Routine: Identifiable, Codable, ObservableObject, Hashable {
    @Published var id: UUID
    @Published var ownerID: String
    @Published var name: String
    @Published var workouts: [Workout]
    
    init(id: UUID = UUID(), ownerID: String = "", name: String = "default",
         workouts: [Workout] = [Workout](), saveOnCreate: Bool = true) {
        self.id = id
        self.name = name
        self.workouts = workouts
        self.ownerID = ownerID
        if (saveOnCreate) {
            save()
        }
        
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    static func == (lhs: Routine, rhs: Routine) -> Bool {
        return lhs.id == rhs.id
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
    
    func get(position: Int) -> Workout {
        return workouts[position]
    }
    
    func setName(name: String) {
        self.name = name
        save()
    }
    
    func addWorkout(newWorkout: Workout) {
        self.workouts.append(newWorkout)
        save()
    }
    
    
    func createWorkout(name: String) -> Workout {
        let newWorkout: Workout = Workout(name: name)
        self.addWorkout(newWorkout: newWorkout)
        save()
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
        //UserDefaults.standard.set(self, forKey: id.uuidString)
        
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: id.uuidString)
        }
    }
    
    func SQLSave() {
        
    }
}

class Workout: Identifiable, Codable, ObservableObject, Hashable {
    @Published var id: UUID
    
    @Published var name: String
    @Published var exercises: [ExerciseSet]
    @Published var notes: String
    
    init(id: UUID = UUID(), name: String = "default", exercises: [ExerciseSet] = [ExerciseSet](),
        saveOnCreate: Bool = true) {
        self.id = id
        self.name = name
        self.notes = ""
        self.exercises = exercises
        if (saveOnCreate) {
            save()
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id
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
        save()
    }
    
    func addExercise(newExercise: ExerciseSet) {
        exercises.append(newExercise)
        save()
    }
    
    func addExercise(newExercise: Exercise) {
        exercises.append(ExerciseSet(exerciseInfo: newExercise))
        save()
    }
    
    func removeExercise(atPos: Int) {
        exercises.remove(at: atPos)
        save()
    }
    
    func save() {
        localSave()
        SQLSave()
    }
    
    func localSave() {
        //saves this info, and the info of all the exersizeSets if changed
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: id.uuidString)
        }
    }
    
    func SQLSave() {
        
    }
}

class ExerciseSet: Identifiable, Codable, ObservableObject, Hashable {
    @Published var id: UUID
    
    @Published var name: String
    @Published var exerciseInfo: Exercise
    @Published var repList: [Int]
    @Published var intensityForm: IntensityType
    @Published var intensityList: [Int]
    @Published var restLengths: [Int] //in seconds
    @Published var notes: String
    
    init(id: UUID = UUID(), exerciseInfo: Exercise = Exercise(),
         intensityForm: IntensityType = IntensityType.None, saveOnCreate: Bool = true) {
        self.id = id
        self.name = exerciseInfo.name
        self.notes = ""
        
        self.exerciseInfo = exerciseInfo
        self.intensityForm = intensityForm
        self.intensityList = []
        self.repList = [12,12,12]
        self.restLengths = [90,90,90]
        self.setIntensityListToDefaults()
        if (saveOnCreate) {
            save()
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    static func == (lhs: ExerciseSet, rhs: ExerciseSet) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case exerciseInfo
        case repList
        case intensityForm
        case intensityList
        case restLengths
        case notes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        notes = try container.decode(String.self, forKey: .notes)
        exerciseInfo = try container.decode(Exercise.self, forKey: .exerciseInfo)
        repList = try container.decode([Int].self, forKey: .repList)
        intensityForm = try container.decode(IntensityType.self, forKey: .intensityForm)
        intensityList = try container.decode([Int].self, forKey: .intensityList)
        restLengths = try container.decode([Int].self, forKey: .restLengths)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
        try container.encode(notes, forKey: .notes)
        try container.encode(exerciseInfo, forKey: .exerciseInfo)
        try container.encode(repList, forKey: .repList)
        try container.encode(intensityForm, forKey: .intensityForm)
        try container.encode(intensityList, forKey: .intensityList)
        try container.encode(restLengths, forKey: .restLengths)
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
    
    func save() {
        localSave()
        SQLSave()
    }
    
    func localSave() {
        //saves this info, and the info of all the exersizeSets if changed
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: id.uuidString)
        }
    }
    
    func SQLSave() {
        
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
    let primaryMusclesWorked: [Muscles]
    let secondaryMusclesWorked: [Muscles]
    
    init(id: UUID = UUID(), name: String = "default", primaryMusclesWorked: [Muscles] = [], secondaryMusclesWorked: [Muscles] = []) {
        self.id = id
        self.name = name
        self.primaryMusclesWorked = primaryMusclesWorked
        self.secondaryMusclesWorked = secondaryMusclesWorked
    }
}

class WorkoutRecord {
    @Published var id: UUID
    @Published var userID: String
    
    @Published var date: Date
    @Published var exercises: [ExerciseRecord]
    
    init(id: UUID = UUID(), userID: String, date: Date, exercises: [ExerciseRecord] = []) {
        self.id = id
        self.userID = userID
        self.date = date
        self.exercises = exercises
    }
    
    enum CodingKeys: CodingKey {
        case id
        case userID
        case date
        case exercises
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userID = try container.decode(String.self, forKey: .userID)
        date = try container.decode(Date.self, forKey: .date)
        exercises = try container.decode([ExerciseRecord].self, forKey: .exercises)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userID, forKey: .userID)
        try container.encode(date, forKey: .date)
        try container.encode(exercises, forKey: .exercises)
    }
    
    func addExerciseRecord(exerciseRecord: ExerciseRecord) {
        exercises.append(exerciseRecord)
    }
}

class ExerciseRecord: Identifiable, Codable {
    @Published var id: UUID
    
    @Published var exercise: Exercise
    @Published var sets: [Set]
    
    init(id: UUID = UUID(), exercise: Exercise, sets: [Set] = []) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
    }
    
    enum CodingKeys: CodingKey {
        case id
        case exercise
        case sets
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        exercise = try container.decode(Exercise.self, forKey: .exercise)
        sets = try container.decode([Set].self, forKey: .sets)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(exercise, forKey: .exercise)
        try container.encode(sets, forKey: .sets)
    }
}

struct Set: Codable {
    var reps: Int
    var weight: Int
}

enum Muscles: Codable {
    case quad, hamstring, calf,
        chest, tricep, shoulder,
        back, bicep
}

enum IntensityType: Codable {
    case RPE, PercentOfMax, None
}
