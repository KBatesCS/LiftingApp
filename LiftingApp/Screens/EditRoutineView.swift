//
//  EditRoutineView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/20/24.
//

import SwiftUI

struct EditRoutineView: View {
    @ObservedObject var routineList: RoutineList
    @ObservedObject var routine: Routine
    private var isNew: Bool
    
    init(curRoutine: Routine, routineList: RoutineList) {
        self.routine = curRoutine
        self.isNew = false
        self.routineList = routineList
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
                    .onChange(of: routine.name) { _ in
                        routine.save()
                        if let index = routineList.routines.firstIndex(where: { $0.id == routine.id }) {
                            routineList.routines[index] = routine
                        }
                    }
                /*
                List(Array(routine.workouts.enumerated()), id: \.element.id) { index, workout in
                    NavigationLink(destination: EditWorkoutView(routine: self.routine, position: index)) {
                        WorkoutMetaDislay(workout: workout)
                    }
                }
                 */
                
                List(routine.workouts.indices, id: \.self) { index in
                    if let data = UserDefaults.standard.data(forKey: routine.workouts[index].id.uuidString) {
                        if let loadedWorkout = try? JSONDecoder().decode(Workout.self, from: data) {
                            NavigationLink(destination: EditWorkoutView(routine: routine, workout: loadedWorkout)) {
                                Text(loadedWorkout.name)
                            }
                        }
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
    EditRoutineView(curRoutine: Routine(name: "new routine"), routineList: RoutineList())
}
