//
//  CustomFunctions.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/12/24.
//

import Foundation

func load<T: Codable>(key: String) -> T? {
    var out: T
    if let data = UserDefaults.standard.data(forKey: key) {
        if let decoded = try? JSONDecoder().decode(T.self, from: data) {
            out = decoded
            return out
        }
    }
    return nil
}

func loadExercise(uuid: UUID?) -> Exercise {
    if uuid == nil {
        return Exercise()
    }
    var exercises: [Exercise] = Bundle.main.decode("defaultData.json")
    for exercise in exercises {
        if exercise.id == uuid! {
            return exercise
        }
    }
    return Exercise()
}

func save<T: Codable>(key: String, data: T) {
    do {
        let encoded = try JSONEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: key)
    } catch {
        print("Failed to encode data:", error)
    }
}

/*
 func getWorkoutNameFromID(workoutID: UUID, routineList: RoutineList) -> String {
 for routine in routineList.routines {
 for workout in routine.workouts {
 if workout.id == workoutID {
 return workout.name
 }
 }
 }
 return ""
 }
 */
