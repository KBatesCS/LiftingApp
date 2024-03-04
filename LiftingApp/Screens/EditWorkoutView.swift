//
//  EditWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/21/24.
//

import SwiftUI

struct EditWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var workout: Workout
    @ObservedObject var routine: Routine
    
    init (routine: Routine, workout: Workout) {
        self.routine = routine
        self.workout = workout
    }
    
    
    var body: some View {
        VStack {
            TextField("name", text: $workout.name)
                .textFieldStyle(RoundedTextFieldStyle())
                .frame(alignment: .topLeading)
                .padding()
                .onChange(of: workout.name){ _ in
                    workout.save()
                    if let index = routine.workouts.firstIndex(where: { $0.id == workout.id }) {
                        routine.workouts[index] = workout
                    }
                }
            Spacer()
            
            List(Array(workout.exercises.enumerated()), id: \.element.id) { index, eset in
                ExerciseSetDisplay(eset: eset)
                
            }
            
            
            Button (action: {
                workout.addExercise(newExercise: Exercise())
            }, label: {
                Text("+ exersize")
                    .font(.title2)
                    .foregroundColor(Color("Background"))
                    .bold()
            })
            //.frame(alignment: .topLeading)
            Spacer()
            
            
            Text("hi")
        }
        /*
        .onAppear {
            if (self.isNew) {
                self.routine.addWorkout(newWorkout: self.workout)
            }
            self.name = self.workout.name
        }
         */
    }
}

struct ExerciseSetDisplay: View {
    
    let eset: ExerciseSet
    
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
            Text(eset.name)
            List(eset.repList.indices, id: \.self) { index in
                Text("Item \(eset.repList[index])")
                
            }
        }
        .padding()
    }
}

#Preview {
    EditWorkoutView(routine: Routine(), workout: Workout())
}
