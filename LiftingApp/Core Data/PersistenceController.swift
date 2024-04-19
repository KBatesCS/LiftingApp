//
//  PersistenceController.swift
//  LiftingApp
//
//  Created by Kevin Bates on 4/17/24.
//

import Foundation
import CoreData

struct PersistenceController {
    
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        self.container = NSPersistentContainer(name: "LiftingApp")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Error loading container: \(error), \(error.userInfo)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("error saving context \(error)")
        }
    }
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        //example of stuff in memory for preview
        
        let workoutRecord = CDWorkoutRecord(notes: "lift lighter next time", usrStr: "ExampleUser", workoutUUID: UUID(), context: context)
        
        
        let exercise1 = CDExerciseRecord(inLBs: true, exercise: loadExercise(uuid: UUID(uuidString: "2ABFB8CA-E493-4EC8-B04A-45FDDF7D92A4")), orderLoc: 1, context: context)
        
        let set11 = CDSetRecord(reps: 8, weight: 135, completed: true, orderLoc: 1, context: context)
        let set12 = CDSetRecord(reps: 8, weight: 140, completed: true, orderLoc: 2, context: context)
        let set13 = CDSetRecord(reps: 8, weight: 145, completed: false, orderLoc: 3, context: context)
        
        exercise1.sets.append(set11)
        exercise1.sets.append(set12)
        exercise1.sets.append(set13)
        
        workoutRecord.exercises.append(exercise1)
        
        let exercise2 = CDExerciseRecord(inLBs: false, exercise: loadExercise(uuid: UUID(uuidString: "D51D5334-871D-482B-94C0-097F98E39E2C")), orderLoc: 2, context: context)
        
        let set21 = CDSetRecord(reps: 12, weight: 0, completed: true, orderLoc: 1, context: context)
        let set22 = CDSetRecord(reps: 12, weight: 0, completed: true, orderLoc: 2, context: context)
        let set23 = CDSetRecord(reps: 12, weight: 0, completed: true, orderLoc: 3, context: context)
        
        exercise2.sets.append(set21)
        exercise2.sets.append(set22)
        exercise2.sets.append(set23)
        
        workoutRecord.exercises.append(exercise2)
        
        let exercise3 = CDExerciseRecord(inLBs: true, exercise: loadExercise(uuid: UUID(uuidString: "6C05802B-BFC0-4210-BE3D-DF44A5A137D9")), orderLoc: 3, context: context)
        
        let set31 = CDSetRecord(reps: 10, weight: 35, completed: true, orderLoc: 1, context: context)
        let set32 = CDSetRecord(reps: 8, weight: 40, completed: true, orderLoc: 2, context: context)
        let set33 = CDSetRecord(reps: 6, weight: 45, completed: false, orderLoc: 3, context: context)
        
        exercise3.sets.append(set31)
        exercise3.sets.append(set32)
        exercise3.sets.append(set33)
        
        workoutRecord.exercises.append(exercise3)
        
        let workoutRecord2 = CDWorkoutRecord(date: Date.now.startOfMonth, usrStr: "ExampleUser", workoutUUID: UUID(), context: context)
        
        
        let workoutRecord3 = CDWorkoutRecord(date: Date.now, usrStr: "ExampleUser", workoutUUID: UUID(), context: context)
        
        let workoutRecord4 = CDWorkoutRecord(date: Date.now.firstWeekDayBeforeStart, notes: "lift lighter next time", usrStr: "ExampleUser", workoutUUID: UUID(), context: context)
        
        
        // ---------------------------------------
        
        
        let workoutRoutine1 = CDWorkoutRoutine(name: "PPL", notes: "GO HARD DO BETTER", userStr: "ExampleUser", orderLoc: 1, context: context)
        
        let workout11 = CDWorkout(name: "Push", orderLoc: 1, context: context)
        
        let exerciseSet111 = CDExerciseSet(exercise: loadExercise(uuid: UUID(uuidString: "2ABFB8CA-E493-4EC8-B04A-45FDDF7D92A4")), intensityType: IntensityType.PercentOfMax, orderLoc: 1, context: context)
        
        let set1111 = CDSet(targetReps: "4", intensity: 85, orderLoc: 1, context: context)
        let set1112 = CDSet(targetReps: "4", intensity: 87.5, orderLoc: 2, context: context)
        let set1113 = CDSet(targetReps: "4", intensity: 90, orderLoc: 3, context: context)
        
        exerciseSet111.sets.append(set1111)
        exerciseSet111.sets.append(set1112)
        exerciseSet111.sets.append(set1113)
        
        workout11.exercises.append(exerciseSet111)
        
        let exerciseSet112 = CDExerciseSet(exercise: loadExercise(uuid: UUID(uuidString: "6C05802B-BFC0-4210-BE3D-DF44A5A137D9")), intensityType: IntensityType.RPE, orderLoc: 2, context: context)
        
        let set1121 = CDSet(targetReps: "10", intensity: 8, orderLoc: 1, context: context)
        let set1122 = CDSet(targetReps: "10", intensity: 8, orderLoc: 2, context: context)
        let set1123 = CDSet(targetReps: "10", intensity: 9, orderLoc: 3, context: context)
        
        exerciseSet112.sets.append(set1121)
        exerciseSet112.sets.append(set1122)
        exerciseSet112.sets.append(set1123)
        
        workout11.exercises.append(exerciseSet112)
        
        let exerciseSet113 = CDExerciseSet(exercise: loadExercise(uuid: UUID(uuidString: "D51D5334-871D-482B-94C0-097F98E39E2C")), orderLoc: 3, context: context)
        
        let set1131 = CDSet(targetReps: "10", intensity: 8, orderLoc: 1, context: context)
        let set1132 = CDSet(targetReps: "10", intensity: 8, orderLoc: 2, context: context)
        let set1133 = CDSet(targetReps: "10", intensity: 9, orderLoc: 3, context: context)
        
        exerciseSet113.sets.append(set1131)
        exerciseSet113.sets.append(set1132)
        exerciseSet113.sets.append(set1133)
        
        workout11.exercises.append(exerciseSet113)
        
        workoutRoutine1.workouts.append(workout11)
        
        let workout12 = CDWorkout(name: "Pull", orderLoc: 2, context: context)
        let workout13 = CDWorkout(name: "Legs", orderLoc: 3, context: context)
        
        workoutRoutine1.workouts.append(workout12)
        workoutRoutine1.workouts.append(workout13)
        
        let workoutRoutine2 = CDWorkoutRoutine(name: "Bro Split", userStr: "ExampleUser", orderLoc: 2, context: context)
        
        
        return controller
    }()
    
}
