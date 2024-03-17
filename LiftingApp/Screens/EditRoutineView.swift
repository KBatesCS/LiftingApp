//
//  EditRoutineView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/20/24.
//

import SwiftUI

struct EditRoutineView: View {
    @EnvironmentObject var routineList: RoutineList
    @ObservedObject var routine: Routine
    @State var refresh: Bool = true
    
    @State private var isShowingDeleteConfirmation = false
    @State private var deletionIndexSet: IndexSet?
    
    
    /*
     @ObservedObject var routine: Routine
     init(routine: Routine) {
     self.routine = routine
     }
     */
    
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
                        routineList.refreshAndSave()
                    }
                
                
                List {
                    ForEach(routine.workouts) { workout in
                        NavigationLink(destination: EditWorkoutView(workout: workout)) {
                            Text(workout.name)
                        }
                        .foregroundColor(Color("Text"))
                        .listRowBackground(Color("Accent"))
                    }
                    .onDelete { indexSet in
                        deletionIndexSet = indexSet
                        isShowingDeleteConfirmation = true
                    }
                }
                .listRowSpacing(10)
                .alert(isPresented: $isShowingDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Workout"),
                        message: Text("Are you sure you want to delete this workout?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let indexSet = deletionIndexSet {
                                routine.workouts.remove(atOffsets: indexSet)
                                routineList.refreshAndSave()
                            }
                            // Reset deletion state
                            deletionIndexSet = nil
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                
                Button (action: {
                    //routine.addWorkout(newWorkout: Workout(name: "Day \(routine.workouts.count + 1)"))
                    routine.workouts.append(Workout(name: "Day \(routine.workouts.count + 1)"))
                    routineList.refreshAndSave()
                    //refresh.toggle()
                    
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

/*
 #Preview {
 //EditRoutineView(curRoutine: Routine(name: "new routine"))
 //.environment(Routine())
 }
 */
