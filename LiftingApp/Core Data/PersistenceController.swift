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
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        //example of stuff in memory for preview
        /*
        let workoutRecord = CDWorkoutRecord(notes: "lift lighter next time", usrStr: "ExampleUser", workoutUUID: UUID(), context: context)
        
        
        let exercise1 = CDExerciseRecord(inLBs: true, exercise: loadExercise(uuid: UUID(uuidString: "2ABFB8CA-E493-4EC8-B04A-45FDDF7D92A4")), context: context)
        
        let set11 = CDSetRecord(reps: 8, weight: 135, completed: true, context: context)
        let set12 = CDSetRecord(reps: 8, weight: 140, completed: true, context: context)
        let set13 = CDSetRecord(reps: 8, weight: 145, completed: false, context: context)
        
        exercise1.sets.insert(set11)
        exercise1.sets.insert(set12)
        exercise1.sets.insert(set13)
        
        workoutRecord.exercises.insert(exercise1)
        
        let exercise2 = CDExerciseRecord(inLBs: false, exercise: loadExercise(uuid: UUID(uuidString: "D51D5334-871D-482B-94C0-097F98E39E2C")), context: context)
        
        let set21 = CDSetRecord(reps: 12, weight: 0, completed: true, context: context)
        let set22 = CDSetRecord(reps: 12, weight: 0, completed: true, context: context)
        let set23 = CDSetRecord(reps: 12, weight: 0, completed: true, context: context)
        
        exercise1.sets.insert(set21)
        exercise1.sets.insert(set22)
        exercise1.sets.insert(set23)
        
        workoutRecord.exercises.insert(exercise2)
        
        let exercise3 = CDExerciseRecord(inLBs: true, exercise: loadExercise(uuid: UUID(uuidString: "6C05802B-BFC0-4210-BE3D-DF44A5A137D9")), context: context)
        
        let set31 = CDSetRecord(reps: 10, weight: 35, completed: true, context: context)
        let set32 = CDSetRecord(reps: 8, weight: 40, completed: true, context: context)
        let set33 = CDSetRecord(reps: 6, weight: 45, completed: false, context: context)
        
        exercise1.sets.insert(set31)
        exercise1.sets.insert(set32)
        exercise1.sets.insert(set33)
        
        workoutRecord.exercises.insert(exercise3)
        
        let workoutRecord2 = CDWorkoutRecord(date: Date.now.startOfMonth, usrStr: "ExampleUser", workoutUUID: UUID(), context: context)
        
        let workoutRecord3 = CDWorkoutRecord(date: Date.now.firstWeekDayBeforeStart, usrStr: "ExampleUser", workoutUUID: UUID(), context: context)
        
        let workoutRecord4 = CDWorkoutRecord(date: Date.now.firstWeekDayBeforeStart, notes: "lift lighter next time", usrStr: "ExampleUser", workoutUUID: UUID(), context: context)
        */
        
        
        return controller
    }()
    
}
