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
    private var isNew: Bool
    private var pos: Int
    
    @State private var name: String = ""
    
    
    /*
    init (workout: Workout? = nil, routine: Routine) {
        if (workout == nil) {
            self.isNew = true
            let newWorkout = Workout(name: "Day \(routine.workouts.count + 1)")
            //routine.addWorkout(newWorkout: newWorkout)
            self.workout = newWorkout
        } else {
            self.workout = workout ?? Workout(name: "should never")
            self.isNew = false
        }
        
        self.routine = routine
    }
    */
    
    init (routine: Routine, position: Int) {
        self.routine = routine
        
        if (position >= routine.workouts.count) {
            self.workout = Workout(name: "Day \(routine.workouts.count + 1)")
            self.isNew = true
            self.pos = position - 1
        } else {
            self.workout = routine.get(position: position)
            self.isNew = false
            self.pos = position
        }
    }
    
    
    var body: some View {
        VStack {
            HStack {
                TextField("name", text: $name)
                    .textFieldStyle(RoundedTextFieldStyle())
                    .frame(alignment: .topLeading)
                    .padding()
                
                Button (action: {
                    save()
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "square.and.arrow.down")
                        .imageScale(.large)
                })
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
        .onAppear {
            if (self.isNew) {
                self.routine.addWorkout(newWorkout: self.workout)
            }
            self.name = self.workout.name
        } 
    }
    func save() {
       //self.workout.name = name
        self.routine.workouts[pos].name = name
    }
}



#Preview {
    EditWorkoutView(routine: Routine(), position: 0)
}
