//
//  CD Routine + Helper.swift
//  LiftingApp
//
//  Created by Kevin Bates on 4/18/24.
//

import Foundation
import CoreData

extension CDSet {
    
    var uuid: UUID {
        #if DEBUG
        uuid_!
        #else
        uuid_ ?? UUID()
        #endif
    }
    
    var targetReps: String {
        get { targetReps_ ?? "" }
        set { targetReps_ = newValue }
    }
    
    var orderLoc: Int {
        get { Int(orderLoc_) }
        set { orderLoc_ = Int32(newValue)}
    }
    
    var intensity: Float {
        get { Float(intensity_) }
        set { intensity_ = Float(newValue) }
    }
    
    convenience init(targetReps: String, intensity: Float, orderLoc: Int, context: NSManagedObjectContext) {
        self.init(context: context)
        self.targetReps = targetReps
        self.intensity = intensity
        self.orderLoc = orderLoc
    }
    
    public override func awakeFromInsert() {
        self.uuid_ = UUID()
    }
    
    static func delete(set: CDWorkoutRecord) {
        guard let context = set.managedObjectContext else { return }
        context.delete(set)
    }
    
    static func fetch(_ predicate: NSPredicate = .all) -> NSFetchRequest<CDSet> {
        let request = CDSet.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDSet.orderLoc_, ascending: true),
                                   NSSortDescriptor(keyPath: \CDSet.uuid_, ascending:  true)]
        request.predicate = predicate
        
        return request
    }
}

extension CDExerciseSet {
    var uuid: UUID {
        #if DEBUG
        uuid_!
        #else
        uuid_ ?? UUID()
        #endif
    }
    
    var intensityType: IntensityType {
        get { IntensityType(rawValue: intensityType_) ?? IntensityType.None }
        set { intensityType_ = newValue.rawValue }
    }
    
    var orderLoc: Int {
        get { Int(orderLoc_) }
        set { orderLoc_ = Int32(newValue)}
    }
    
    var exercise: Exercise {
        get { loadExercise(uuid: exercise_) }
        set { exercise_ = (newValue as Exercise).id }
    }
    
    var restLength: Int {
        get { Int(restLength_) }
        set { restLength_ = Int32(newValue) }
    }
    
    var sets: [CDSet] {
        get {( sets_ as? Set<CDSet> )?.sorted{$0.orderLoc < $1.orderLoc} ?? []}
        set { sets_ = NSSet(array: newValue)}
    }
    
    convenience init(exercise: Exercise, intensityType: IntensityType = IntensityType.None, restLength: Int = 90, orderLoc: Int, context: NSManagedObjectContext) {
        self.init(context: context)
        self.exercise = exercise
        self.intensityType = intensityType
        self.restLength = restLength
        self.orderLoc = orderLoc
    }
    
    public override func awakeFromInsert() {
        self.uuid_ = UUID()
    }
    
    static func delete(exerciseSet: CDExerciseSet) {
        guard let context = exerciseSet.managedObjectContext else { return }
        context.delete(exerciseSet)
    }
    
    static func fetch(_ predicate: NSPredicate = .all) -> NSFetchRequest<CDExerciseSet> {
        let request = CDExerciseSet.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDExerciseSet.orderLoc_, ascending: true),
                                   NSSortDescriptor(keyPath: \CDExerciseSet.uuid_, ascending:  true)]
        request.predicate = predicate
        
        return request
    }
}

extension CDWorkout {
    var uuid: UUID {
        #if DEBUG
        uuid_!
        #else
        uuid_ ?? UUID()
        #endif
    }
    
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
    
    var notes: String {
        get { notes_ ?? "" }
        set { notes_ = newValue }
    }
    
    var exercises: [CDExerciseSet] {
        get {( exercises_ as? Set<CDExerciseSet> )?.sorted{$0.orderLoc < $1.orderLoc} ?? []}
        set { exercises_ = NSSet(array: newValue)}
    }
    
    var orderLoc: Int {
        get { Int(orderLoc_) }
        set { orderLoc_ = Int32(newValue)}
    }
    
    convenience init(name: String, notes: String = "", orderLoc: Int, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        self.notes = notes
        self.orderLoc = orderLoc
    }
    
    public override func awakeFromInsert() {
        self.uuid_ = UUID()
    }
    
    static func delete(workout: CDWorkout) {
        guard let context = workout.managedObjectContext else { return }
        context.delete(workout)
    }
    
    static func fetch(_ predicate: NSPredicate = .all) -> NSFetchRequest<CDWorkout> {
        let request = CDWorkout.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDWorkout.orderLoc_, ascending: true),
                                   NSSortDescriptor(keyPath: \CDWorkout.uuid_, ascending:  true)]
        request.predicate = predicate
        
        return request
    }
    
}

extension CDWorkoutRoutine {
    var uuid: UUID {
        #if DEBUG
        uuid_!
        #else
        uuid_ ?? UUID()
        #endif
    }
    
    var orderLoc: Int {
        get { Int(orderLoc_) }
        set { orderLoc_ = Int32(newValue)}
    }
    
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
    
    var userStr: String {
        get { userStr_ ?? "" }
        set { userStr_ = newValue }
    }
    
    var workouts: [CDWorkout] {
        get {( workouts_ as? Set<CDWorkout> )?.sorted{$0.orderLoc < $1.orderLoc} ?? []}
        set { workouts_ = NSSet(array: newValue)}
    }
    
    convenience init(name: String, notes: String = "", userStr: String, orderLoc: Int, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        self.userStr = userStr
        self.orderLoc = orderLoc
    }
    
    public override func awakeFromInsert() {
        self.uuid_ = UUID()
    }
    
    static func delete(workoutRoutine: CDWorkoutRoutine) {
        guard let context = workoutRoutine.managedObjectContext else { return }
        context.delete(workoutRoutine)
    }
    
    static func fetch(_ predicate: NSPredicate = .all) -> NSFetchRequest<CDWorkoutRoutine> {
        let request = CDWorkoutRoutine.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDWorkoutRoutine.orderLoc_, ascending: true),
                                   NSSortDescriptor(keyPath: \CDWorkoutRoutine.uuid_, ascending:  true)]
        request.predicate = predicate
        
        return request
    }
}
