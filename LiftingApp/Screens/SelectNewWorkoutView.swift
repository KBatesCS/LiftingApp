//
//  SelectNewWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/4/24.
//

import SwiftUI

struct SelectNewWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var routineList: RoutineList
    
    private var exerciseList: [Exercise] = []
    @ObservedObject var eSet: ExerciseSet
    @ObservedObject var workout: Workout
    private var isNew: Bool
    
    init(workout: Workout, eSet: ExerciseSet?) {
        self.workout = workout
        if (eSet == nil) {
            self.eSet = ExerciseSet(saveOnCreate: false)
            self.isNew = true
        } else {
            self.eSet = eSet!
            self.isNew = false
        }
        exerciseList = getExercises()
    }
    
    var body: some View {

        
        List(Array(exerciseList.enumerated()), id: \.element.id) { index, exercise in
            exerciseDisplay(exercise: exercise)
                .onTapGesture {
                    eSet.exerciseInfo = exercise
                    //eSet.save()
                    if (isNew) {
                        workout.addExercise(newExercise: eSet)
                    }
                    /*
                    if let i = workout.exercises.firstIndex(where: { $0.id == eSet.id }) {
                        workout.exercises[i] = eSet
                    }*/
                    routineList.refreshAndSave()
                    presentationMode.wrappedValue.dismiss()
                    
                }
        }
    }

    
    func getExercises() -> [Exercise] {
        let e1 = Exercise(name: "BenchPress", primaryMusclesWorked: [Muscles.chest], secondaryMusclesWorked: [Muscles.shoulder, Muscles.tricep])
        let e2 = Exercise(name: "Pullup", primaryMusclesWorked: [Muscles.back], secondaryMusclesWorked: [Muscles.bicep])
        let lout: [Exercise] = [e1, e2]
        return lout
    }
}

struct exerciseDisplay: View {
    var exercise: Exercise
    
    var body: some View {
        Text(exercise.name)
            .contentShape(Rectangle())
    }
}

#Preview {
    SelectNewWorkoutView(workout: Workout(), eSet: nil)
}
