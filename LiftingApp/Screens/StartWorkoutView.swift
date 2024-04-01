//
//  StartWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/25/24.
//

import SwiftUI

struct StartWorkoutView: View {
    
    @EnvironmentObject private var routineList: RoutineList
    @EnvironmentObject private var activeWorkoutInfo: ActiveWorkoutViewData
    
    @State private var selectedRoutine: Routine = Routine(name: "Select A Routine", saveOnCreate: false)
    
    @State private var selectedWorkout: Workout = Workout(name: "no workout selected", saveOnCreate: false)
    
    @State private var isShowingActiveWorkout = false
//    @State private var activeViewHolder: ActiveWorkoutViewHolder
    @State var currActiveWorkoutView: ActiveWorkoutView? = nil
    
    var body: some View {
        ZStack {
            Color("Background").edgesIgnoringSafeArea(.all)
            NavigationStack {
                
                VStack {
                    Spacer()
                    Spacer()
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
                        .scaleEffect(1.75)
                        .foregroundStyle(Color("Text"))
                        .underline()
                        .padding(.top)
                    }
                    .onChange(of: selectedRoutine) { _ in
                        save(key: "ExampleUser/SelectedRoutine", data: selectedRoutine)
                    }
                    .onAppear {
                        if let SLRT: Routine = load(key: "ExampleUser/SelectedRoutine") {
                            if let foundRT = routineList.routines.first(where: {$0.id == SLRT.id}) {
                                self.selectedRoutine = foundRT
                                if let SLWO: Workout = load(key: "ExampleUser/SelectedWorkout") {
                                    if let foundWO = selectedRoutine.workouts.first(where: {$0.id == SLWO.id}) {
                                        self.selectedWorkout = foundWO
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    List {
                        ForEach(selectedRoutine.workouts) { workout in
                            HStack {
                                Text(workout.name)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .foregroundColor(workout == selectedWorkout ? Color("Text") :
                                                Color("Text"))
                            .listRowBackground(workout == selectedWorkout ? .gray :
                                                Color("Accent"))
                            .onTapGesture {
                                selectedWorkout = workout
                                save(key: "ExampleUser/SelectedWorkout", data: selectedWorkout)
                            }
                        }
                    }
                    .listRowSpacing(10)
                    //            .onChange(of: selectedWorkout) { _ in
                    //                save(key: "ExampleUser/SelectedWorkout", data: selectedWorkout)
                    //            }
                    
                    Spacer()
                    
                    if activeWorkoutInfo.workoutName == nil || activeWorkoutInfo.startTime == nil || activeWorkoutInfo.displayInfo == nil {
                        NavigationLink(destination: ActiveWorkoutView(workout: selectedWorkout)) {
                            Text("Begin")
                                .font(.title2)
                                .foregroundColor(Color("Text"))
                                .bold()
                                .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
                                .background(Color("Accent"))
                                .cornerRadius(21)
                                .padding()
                        }
                    } else {
                        NavigationLink(destination: ActiveWorkoutView(workoutDisplay: activeWorkoutInfo.displayInfo!, startTime: activeWorkoutInfo.startTime!, workoutName: activeWorkoutInfo.workoutName!)) {
                            Text("Continue")
                                .font(.title2)
                                .foregroundColor(Color("Text"))
                                .bold()
                                .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
                                .background(Color("Accent"))
                                .cornerRadius(21)
                                .padding()
                        }
                    }
                    /*
                    
                    if activeWorkoutInfo.workoutName == nil {
                        Button(action: {
                            if currActiveWorkoutView == nil {
                                currActiveWorkoutView = ActiveWorkoutView(workout: selectedWorkout)
                            }
                            isShowingActiveWorkout = true
                        }) {
                            Text("Begin")
                                .font(.title2)
                                .foregroundColor(Color("Text"))
                                .bold()
                                .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
                                .background(Color("Accent"))
                                .cornerRadius(21)
                                .padding()
                        }
                    }
                     */
                    
                    /*
                    Button(action: {
                        if activeViewHolder.currActiveWorkoutView == nil {
                            currentActiveWorkoutView = ActiveWorkoutView(workout: selectedWorkout, activeViewHolder: activeViewHolder)
                        }
                        isShowingActiveWorkout = true
                    }) {
                        Text("Begin")
                            .font(.title2)
                            .foregroundColor(Color("Text"))
                            .bold()
                            .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
                            .background(Color("Accent"))
                            .cornerRadius(21)
                            .padding()
                    }
                    .sheet(isPresented: $isShowingActiveWorkout, onDismiss: {
                        // Perform actions upon dismissal of ActiveWorkoutView
                    }) {
                        ActiveWorkoutView(workout: selectedWorkout)
                    }
                     */
                }
            }
        }
    }
}

class ActiveWorkoutViewData: ObservableObject {
    @Published var displayInfo: ActiveWorkoutDisplay?
    @Published var startTime: Date?
    @Published var workoutName: String?
    
    init(displayInfo: ActiveWorkoutDisplay? = nil, startTime: Date? = nil, workoutName: String? = nil) {
        self.displayInfo = displayInfo
        self.startTime = startTime
        self.workoutName = workoutName
    }
}

/*
#Preview {
    StartWorkoutView()
}
*/
