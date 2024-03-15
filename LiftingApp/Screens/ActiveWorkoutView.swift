//
//  ActiveWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/15/24.
//

import SwiftUI

struct ActiveWorkoutView: View {
    @EnvironmentObject var routineList: RoutineList
    @ObservedObject var activeWorkout: Workout
    
    var body: some View {
        ForEach(activeWorkout.exercises) { exerciseSet in
            Text(exerciseSet.exerciseInfo.name)
        }
    }
}

/*
#Preview {
    ActiveWorkoutView()
}
*/
