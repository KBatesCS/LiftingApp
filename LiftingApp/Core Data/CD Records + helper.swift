//
//  CD Records + helper.swift
//  LiftingApp
//
//  Created by Kevin Bates on 4/16/24.
//

import Foundation
import CoreData


extension CDWorkoutRecord {
    var uuid: UUID {
        #if DEBUG
        uuid_!
        #else
        uuid_ ?? UUID()
        #endif
    }
    
    var totalTime: Int {
        get { Int(totalTime_) }
        set { totalTime_ = Int32(newValue) }
    }
    
    var exercises: [CDExerciseRecord] {
        get {( exercises_ as? Set<CDExerciseRecord> )?.sorted{$0.orderLoc < $1.orderLoc} ?? []}
        set { exercises_ = NSSet(array: newValue)}
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
        get { UUID(uuidString: workoutUUID_ ?? "") ?? UUID() }
        set { workoutUUID_ = newValue.uuidString }
    }
    
    convenience init(date: Date = Date(), notes: String = "", usrStr: String, workoutUUID: UUID, context: NSManagedObjectContext, totalTime: Int) {
        self.init(context: context)
        self.notes = notes
        self.usrStr = usrStr
        self.workoutUUID = workoutUUID
        self.date = date
        self.totalTime = totalTime
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
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDWorkoutRecord.date_, ascending: true)]
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
    
    var sets: [CDSetRecord] {
        get {( sets_ as? Set<CDSetRecord> )?.sorted{$0.orderLoc < $1.orderLoc} ?? []}
        set { sets_ = NSSet(array: newValue)}
    }
    
    convenience init(inLBs: Bool = true, exercise: Exercise, orderLoc: Int32, context: NSManagedObjectContext) {
        self.init(context: context)
        self.inLbs = inLBs
        self.exercise = exercise
        self.orderLoc = orderLoc
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
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDExerciseRecord.orderLoc, ascending: true)]
        request.predicate = predicate
        
        return request
    }
}
 

extension CDSetRecord {
    var uuid: UUID {
        #if DEBUG
        uuid_!
        #else
        uuid_ ?? UUID()
        #endif
    }
    
    convenience init(reps: Int32, weight: Double, completed: Bool, orderLoc: Int32, context: NSManagedObjectContext) {
        self.init(context: context)
        self.reps = reps
        self.weight = weight
        self.completed = completed
        self.orderLoc = orderLoc
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
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDSetRecord.orderLoc, ascending: true)]
        request.predicate = predicate
        
        return request
    }
    
    static var example: CDSetRecord {
        let context = PersistenceController.preview.container.viewContext
        let set = CDSetRecord(reps: 10, weight: 320, completed: true, orderLoc: 1, context: context)
        return set
    }
}

extension CDSetRecord: Comparable {
    public static func < (lhs: CDSetRecord, rhs: CDSetRecord) -> Bool {
        lhs.uuid.uuidString < rhs.uuid.uuidString
    }
}

