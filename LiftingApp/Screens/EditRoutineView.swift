//
//  EditRoutineView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/20/24.
//

import SwiftUI

struct EditRoutineView: View {
    @ObservedObject var routine: Routine
    private var isNew: Bool
    
    @State private var name: String = ""
    
    init(curRoutine: Routine) {
        self.routine = curRoutine
        self.isNew = false
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("RoutineName", text: $routine.name)
                    .frame(alignment: .topLeading)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("Accent"))
                    .textFieldStyle(RoundedTextFieldStyle())
                    .padding()
                    .onSubmit {
                        routine.setName(name: name)
                    }
                List(Array(routine.workouts.enumerated()), id: \.element.id) { index, workout in
                    NavigationLink(destination: EditWorkoutView(routine: self.routine, position: index)) {
                        WorkoutMetaDislay(workout: workout)
                    }
                }
                /*
                NavigationLink {
                    EditWorkoutView(routine: self.curRoutine, position: self.curRoutine.workouts.count)
                } label: {
                    Text("+ workout")
                        .font(.title2)
                        .foregroundColor(Color("Background"))
                        .bold()
                        .frame(alignment: .topLeading)
                        .padding()
                }
                .onTapGesture {
                    self.curRoutine.addWorkout(newWorkout: Workout(name: "ifuns"))
                }*/
                
                Button (action: {
                    routine.addWorkout(newWorkout: Workout(name: "Day \(routine.workouts.count + 1)"))
                    
                }, label: {
                    Text("+ workout")
                        .font(.title2)
                        .foregroundColor(Color("Background"))
                        .bold()
                })
                .frame(alignment: .topLeading)
                .padding()
                 
                
            }
            
            Spacer()
        }
    }
}

struct WorkoutMetaDislay: View {
    
    let workout: Workout
    
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
            Text(workout.name)
        }
        .padding()
    }
    
    
}

#Preview {
    EditRoutineView(curRoutine: Routine(name: "new routine"))
}
