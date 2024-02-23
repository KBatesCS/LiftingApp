//
//  EditWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/21/24.
//

import SwiftUI

struct EditWorkoutView: View {
    var workout: Workout
    private var isNew: Bool
    
    @State private var name: String = ""
    
    init (workout: Workout? = nil) {
        self.workout = workout ?? Workout()
        self.isNew = (workout == nil)
        self.name = self.workout.name
        
    }
    
    var body: some View {
        TextField("name", text: $name)
            .textFieldStyle(RoundedTextFieldStyle())
            .frame(alignment: .topLeading)
        Spacer()
        
        ForEach(0..<workout.exercises.count, id: \.self) {
            let exercise: ExerciseSet = workout.exercises[$0]
            Text(exercise.name)
                .bold()
            Text(exercise.notes)
            Spacer()
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
        
        
        
    }
}



#Preview {
    EditWorkoutView(workout: Workout())
}
