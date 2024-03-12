//
//  StartWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/25/24.
//

import SwiftUI

struct StartWorkoutView: View {
    
    @ObservedObject private var routineList: RoutineList = RoutineList(user: "ExampleUser")
    @State private var selectedRoutine: Routine = Routine(name: "Select A Routine", saveOnCreate: false)
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "ExampleUser") {
            if let decoded = try? JSONDecoder().decode(RoutineList.self, from: data) {
                routineList = decoded
                selectedRoutine = routineList.routines.first ?? Routine(saveOnCreate: false)
            }
        }
    }
    
    init(routineList: RoutineList) {
        self.routineList = routineList
        if let selRT = routineList.routines.first {
            self.selectedRoutine = selRT
        }
    }
    
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
                        if let cur: Routine = load(key: routine.id.uuidString) {
                            Text(cur.name)
                                .tag(cur)
                        }
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
            
            Text(selectedRoutine.name)
            Spacer()
            
            List(selectedRoutine.workouts.indices, id: \.self) { index in
                if let data = UserDefaults.standard.data(forKey: selectedRoutine.workouts[index].id.uuidString) {
                    if let loadedWorkout = try? JSONDecoder().decode(Workout.self, from: data) {
                        Text(loadedWorkout.name)
                    }
                }
            }
            
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
