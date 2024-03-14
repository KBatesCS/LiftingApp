//
//  StartWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/25/24.
//

import SwiftUI

struct StartWorkoutView: View {
    
    @EnvironmentObject private var routineList: RoutineList
    @State private var selectedRoutine: Routine = Routine(name: "Select A Routine", saveOnCreate: false)
    @State private var selectedWorkout: Workout? = nil
    
    var body: some View {
        VStack {
            /*
            Picker("Select Routine", selection: $selectedRoutine) {
                ForEach(routineList.routines) { routine in
                    Text(routine.name)
                }
            }
             */
            
            Menu {
                Picker("", selection: $selectedRoutine) {
                    ForEach(routineList.routines) { routine in
                        Text(routine.name)
                            .tag(routine)
                    }
                }
            } label: {
                HStack {
                    Text(selectedRoutine.name)
                        .bold()
                        .frame(alignment: .top)
                    Image(systemName: "arrowtriangle.down.fill")
                        .scaleEffect(0.7)
                        .underline()
                }
                .underline()
            }
            
            Spacer()
            ScrollView {
                
            }
            
            Spacer()
            
            List(selectedRoutine.workouts) { workout in
                Text(workout.name)
                    .onTapGesture {
                        selectedWorkout = workout
                    }
            }
            
            Spacer()
            
            Button (action: {
                
            }, label: {
                Text("Begin")
                    .font(.title2)
                    .foregroundColor(Color("Background"))
                    .bold()
            })
            .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
            .background(Color("Accent"))
            .cornerRadius(21)
            
            Spacer()
        }
    }
        
}

#Preview {
    StartWorkoutView()
}
