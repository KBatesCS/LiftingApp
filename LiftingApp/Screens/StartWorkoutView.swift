//
//  StartWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/25/24.
//

import SwiftUI

struct StartWorkoutView: View {
    @EnvironmentObject private var activeWorkoutInfo: ActiveWorkoutDisplayContainer
    
    @State private var selectedRoutine: CDWorkoutRoutine?
    @State private var selectedWorkout: CDWorkout?
    
    @FetchRequest(fetchRequest: CDWorkoutRoutine.fetch())
    var workoutRoutines: FetchedResults<CDWorkoutRoutine>
    
    init() {
//        let request = CDWorkoutRoutine.fetch()
//        self._workoutRoutines = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        ZStack {
            Color("Background").edgesIgnoringSafeArea(.all)
            NavigationStack {
                
                VStack {
                    Spacer()
                    Spacer()
                    Menu {
                        Picker("", selection: $selectedRoutine) {
                            ForEach(workoutRoutines) { routine in
                                Text(routine.name)
                                    .tag(routine as CDWorkoutRoutine?)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedRoutine?.name ?? "Select A routine")
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
                        save(key: "ExampleUser/SelectedRoutine", data: selectedRoutine?.uuid)
                    }
                    .onAppear {
                        if let SLRTUUID: UUID = load(key: "ExampleUser/SelectedRoutine") {
                            if let foundRT = workoutRoutines.first(where: {$0.uuid == SLRTUUID}) {
                                self.selectedRoutine = foundRT
                                if let SLWOUUID: UUID = load(key: "ExampleUser/SelectedWorkout") {
                                    if let foundWO = selectedRoutine?.workouts.first(where: {$0.uuid == SLWOUUID}) {
                                        self.selectedWorkout = foundWO
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    List {
                        if selectedRoutine != nil {
                            ForEach(selectedRoutine!.workouts) { workout in
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
                                    save(key: "ExampleUser/SelectedWorkout", data: selectedWorkout?.uuid)
                                }
                            }
                        }
                    }
                    .listRowSpacing(10)
                    //            .onChange(of: selectedWorkout) { _ in
                    //                save(key: "ExampleUser/SelectedWorkout", data: selectedWorkout)
                    //            }
                    
                    Spacer()
                    
                    if let foundDisplay = activeWorkoutInfo.display {
                        NavigationLink(destination: ActiveWorkoutView(workoutDisplay: foundDisplay)) {
                            Text("Continue")
                                .font(.title2)
                                .foregroundColor(Color("Text"))
                                .bold()
                                .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
                                .background(Color("Accent"))
                                .cornerRadius(21)
                                .padding()
                        }
                    } else {
                        if selectedWorkout != nil {
                            
                            NavigationLink(destination: ActiveWorkoutView(workout: selectedWorkout!)) {
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
                    }
                }
            }
        }
    }
}




struct stwPreviewView: View {
    @StateObject private var activeWorkoutInfo: ActiveWorkoutDisplayContainer

    init() {
        _activeWorkoutInfo = StateObject(wrappedValue: ActiveWorkoutDisplayContainer())
    }
    
    var body: some View {
        VStack {
            StartWorkoutView()
        }
            .environmentObject(activeWorkoutInfo)
    }
}

struct StartWorkoutPreview: PreviewProvider {
    static var previews: some View {
        return stwPreviewView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

