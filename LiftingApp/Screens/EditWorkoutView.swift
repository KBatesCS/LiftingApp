//
//  EditWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/21/24.
//

import SwiftUI

struct EditWorkoutView: View {
    @ObservedObject var workout: Workout
    private var isNew: Bool
    
    @State private var name: String = ""
    
    
    
    init (workout: Workout? = nil) {
        self.workout = workout ?? Workout()
        self.isNew = (workout == nil)
    }
    
    
    
    var body: some View {
        VStack {
            
            TextField("name", text: $name)
                .textFieldStyle(RoundedTextFieldStyle())
                .frame(alignment: .topLeading)
                .onAppear {
                    self.name = self.workout.name
                }
            Spacer()
            
            /*
            ForEach(0..<workout.exercises.count, id: \.self) {
                let exercise: ExerciseSet = workout.exercises[$0]
                Text(exercise.name)
                    .bold()
                Text(exercise.notes)
                Spacer()
            }
             */
            
            ForEach(workout.exercises) { exercise in
                Text(exercise.name)
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
    }
}



#Preview {
    EditWorkoutView(workout: Workout())
}
