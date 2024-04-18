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
            UserDefaults.standard.setValue(encoded, forKey: user)
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
    @Published var intensityForm: IntensityType
    @Published var notes: String
    @Published var sets: [WOSet]
    
    init(id: UUID = UUID(), exerciseInfo: Exercise = Exercise(),
         intensityForm: IntensityType = IntensityType.None, saveOnCreate: Bool = true, sets: [WOSet] = []) {
        self.id = id
        self.name = exerciseInfo.name
        self.notes = ""
        
        self.exerciseInfo = exerciseInfo
        self.intensityForm = intensityForm
        self.sets = sets
        self.sets.append(WOSet(reps: 12, intensity: -1, restLength: 90))
        self.sets.append(WOSet(reps: 12, intensity: -1, restLength: 90))
        self.sets.append(WOSet(reps: 12, intensity: -1, restLength: 90))
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
        case intensityForm
        case notes
        case sets
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        notes = try container.decode(String.self, forKey: .notes)
        exerciseInfo = try container.decode(Exercise.self, forKey: .exerciseInfo)
        sets = try container.decode([WOSet].self, forKey: .sets)
        intensityForm = try container.decode(IntensityType.self, forKey: .intensityForm)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
        try container.encode(notes, forKey: .notes)
        try container.encode(exerciseInfo, forKey: .exerciseInfo)
        try container.encode(sets, forKey: .sets)
        try container.encode(intensityForm, forKey: .intensityForm)
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    /*
     func changeIntensityForm(newIntensityForm: IntensityType) {
     if self.intensityForm == newIntensityForm {
     return
     }
     
     self.intensityForm = newIntensityForm
     self.setIntensityListToDefaults()
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
     */
    
    func addSet() {
        let lastSet = sets.last
        sets.append(WOSet(reps: lastSet?.reps ?? 12, intensity: lastSet?.intensity ?? -1, restLength: lastSet?.restLength ?? 90))
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
        if sets.count <= 0 {
            return
        } else if atPos == -1 {
            sets.removeLast()
        } else if atPos > 0 && atPos < sets.count {
            sets.remove(at: atPos)
        }
    }
}

class WOSet: Codable {
    var reps: Int
    var intensity: Int
    var restLength: Int
    
    init(reps: Int, intensity: Int, restLength: Int) {
        self.reps = reps
        self.intensity = intensity
        self.restLength = restLength
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

class RecordList: ObservableObject, Codable, Identifiable {
    @Published var id: UUID
    @Published var userID: String
    @Published var workoutRecords: [WorkoutRecord]
    
    init(id: UUID = UUID(), userID: String, workoutRecords: [WorkoutRecord] = []) {
        self.id = id
        self.userID = userID
        self.workoutRecords = workoutRecords
    }
    
    enum CodingKeys: CodingKey {
        case id
        case userID
        case workoutRecords
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userID = try container.decode(String.self, forKey: .userID)
        workoutRecords = try container.decode([WorkoutRecord].self, forKey: .workoutRecords)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userID, forKey: .userID)
        try container.encode(workoutRecords, forKey: .workoutRecords)
    }
    
    func save() -> Bool {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.setValue(encoded, forKey: "ExampleUser/RecordList")
            return true
        }
        return false
    }
}

class WorkoutRecord: ObservableObject, Codable, Identifiable {
    @Published var id: UUID
    @Published var workoutID: UUID
    
    @Published var date: Date
    @Published var notes: String
    @Published var exercises: [ExerciseRecord]
    
    init(id: UUID = UUID(), workoutID: UUID, date: Date = Date(), exercises: [ExerciseRecord] = [], notes: String = "") {
        self.id = id
        self.workoutID = workoutID
        self.date = date
        self.notes = notes
        self.exercises = exercises
    }
    
    enum CodingKeys: CodingKey {
        case id
        case workoutID
        case date
        case notes
        case exercises
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        workoutID = try container.decode(UUID.self, forKey: .workoutID)
        notes = try container.decode(String.self, forKey: .notes)
        date = try container.decode(Date.self, forKey: .date)
        exercises = try container.decode([ExerciseRecord].self, forKey: .exercises)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(workoutID, forKey: .workoutID)
        try container.encode(date, forKey: .date)
        try container.encode(notes, forKey: .notes)
        try container.encode(exercises, forKey: .exercises)
    }
    
    func addExerciseRecord(exerciseRecord: ExerciseRecord) {
        exercises.append(exerciseRecord)
    }
}

class ExerciseRecord: Identifiable, Codable {
    @Published var id: UUID
    @Published var inLBs: Bool
    
    @Published var exercise: Exercise
    @Published var sets: [SetRecord]
    
    init(id: UUID = UUID(), exercise: Exercise, sets: [SetRecord] = [], inLBs: Bool = true) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.inLBs = inLBs
    }
    
    enum CodingKeys: CodingKey {
        case id
        case exercise
        case sets
        case inLBs
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        exercise = try container.decode(Exercise.self, forKey: .exercise)
        sets = try container.decode([SetRecord].self, forKey: .sets)
        inLBs = try container.decode(Bool.self, forKey: .inLBs)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(exercise, forKey: .exercise)
        try container.encode(sets, forKey: .sets)
        try container.encode(inLBs, forKey: .inLBs)
    }
}

class SetRecord: Identifiable, Codable {
    @Published var id: UUID
    
    @Published var reps: Int
    @Published var weight: Double
    @Published var completed: Bool
    
    init(id: UUID = UUID(), reps: Int, weight: Double, completed: Bool) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.completed = completed
    }
    
    enum CodingKeys: CodingKey {
        case id
        case reps
        case weight
        case completed
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        reps = try container.decode(Int.self, forKey: .reps)
        weight = try container.decode(Double.self, forKey: .weight)
        completed = try container.decode(Bool.self, forKey: .completed)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(reps, forKey: .reps)
        try container.encode(weight, forKey: .weight)
        try container.encode(completed, forKey: .completed)
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



enum IntensityType: Codable {
    case RPE, PercentOfMax, None
}
