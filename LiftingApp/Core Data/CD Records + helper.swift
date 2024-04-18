//
//  CD Records + helper.swift
//  LiftingApp
//
//  Created by Kevin Bates on 4/16/24.
//

import Foundation
import CoreData

/*
extension CDWorkoutRecord {
    var uuid: UUID {
        #if DEBUG
        uuid_!
        #else
        uuid_ ?? UUID()
        #endif
    }
    
    var exercises: Set<CDExerciseRecord> {
        get {( exercises_ as? Set<CDExerciseRecord> ) ?? []}
        set { exercises_ = newValue as NSSet}
    }
    
    var notes: String {
        get { notes_ ?? "" }
        set { notes_ = newValue }
    }
    
    var usrStr: String {
        get { userStr_ ?? "" }
        set { userStr_ = newValue }
    }
    
    var date: Date {
        get { date_ ?? Date() }
        set { date_ = newValue }
    }
    
    var workoutUUID: UUID {
        get { workoutUUID_ ?? UUID() }
        set { workoutUUID_ = newValue }
    }
    
    convenience init(date: Date = Date(), notes: String = "", usrStr: String, workoutUUID: UUID, context: NSManagedObjectContext) {
        self.init(context: context)
        self.notes = notes
        self.usrStr = usrStr
        self.workoutUUID = uuid
        self.date = date
    }
    
    public override func awakeFromInsert() {
        self.uuid_ = UUID()
        date = Date()
    }
    
    static func delete(workoutRecord: CDWorkoutRecord) {
        guard let context = workoutRecord.managedObjectContext else { return }
        context.delete(workoutRecord)
    }
    
    static func fetch(_ predicate: NSPredicate = .all) -> NSFetchRequest<CDWorkoutRecord> {
        let request = CDWorkoutRecord.fetchRequest()
        
        //request.sortDescriptors = [NSSortDescriptor(keyPath: \CDWorkoutRecord.date., ascending: true)]
        request.predicate = predicate
        
        return request
    }
    
}

extension CDExerciseRecord {
    
    var uuid: UUID {
        #if DEBUG
        uuid_!
        #else
        uuid_ ?? UUID()
        #endif
    }
    
    var exercise: Exercise {
        get { loadExercise(uuid: exercise_) }
        
        set { exercise_ = (newValue as Exercise).id }
    }
    
    var sets: Set<CDSetRecord> {
        get {( sets_ as? Set<CDSetRecord> ) ?? []}
        set { sets_ = newValue as NSSet}
    }
    
    convenience init(inLBs: Bool = true, exercise: Exercise, context: NSManagedObjectContext) {
        self.init(context: context)
        self.inLbs = inLBs
        self.exercise = exercise
    }
    
    public override func awakeFromInsert() {
        self.uuid_ = UUID()
    }
    
    static func delete(exerciseRecord: CDExerciseRecord) {
        guard let context = exerciseRecord.managedObjectContext else { return }
        context.delete(exerciseRecord)
    }
    
    static func fetch(_ predicate: NSPredicate = .all) -> NSFetchRequest<CDExerciseRecord> {
        let request = CDExerciseRecord.fetchRequest()
        
        //request.sortDescriptors = [NSSortDescriptor(keyPath: \CDSetRecord., ascending: <#T##Bool#>)]
        request.predicate = predicate
        
        return request
    }
}
 */

extension CDSetRecord {
    var uuid: UUID {
        #if DEBUG
        uuid_!
        #else
        uuid_ ?? UUID()
        #endif
    }
    
    convenience init(reps: Int32, weight: Double, completed: Bool, context: NSManagedObjectContext) {
        self.init(context: context)
        self.reps = reps
        self.weight = weight
        self.completed = completed
    }
    
    public override func awakeFromInsert() {
        self.uuid_ = UUID()
    }
    
    static func delete(setRecord: CDSetRecord) {
        guard let context = setRecord.managedObjectContext else { return }
        context.delete(setRecord)
    }
    
    static func fetch(_ predicate: NSPredicate = .all) -> NSFetchRequest<CDSetRecord> {
        let request = CDSetRecord.fetchRequest()
        
        //request.sortDescriptors = [NSSortDescriptor(keyPath: \CDSetRecord., ascending: <#T##Bool#>)]
        request.predicate = predicate
        
        return request
    }
}

