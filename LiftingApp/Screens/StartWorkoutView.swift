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
                    .frame(alignment: .top)
                    .padding(.bottom, 20)
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
                    
                    ScrollView {
                        if let selectedRoutine = selectedRoutine {
                            ForEach(selectedRoutine.workouts) { workout in
                                
                                let isSelected = workout == selectedWorkout
                                
                                let acc = isSelected ? Color(.accent) : Color(.gray)
                                let bg = isSelected ? Color(.background).opacity(0.8) : Color(.background)
                                
                                Text(workout.name)
                                    .frame(maxWidth: .infinity, minHeight: 60)
                                    
                                    .background {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundStyle(Color(.accent))
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundStyle(bg)
                                        }
                                    }
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .stroke(acc, lineWidth: 3))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .foregroundStyle(acc)
                                    .bold()
                                    .font(.system(size: 20))
                                    .onTapGesture {
                                        selectedWorkout = workout
                                        save(key: "ExampleUser/SelectedWorkout", data: selectedWorkout?.uuid)
                                    }
                            }
                        }
                        
                        
                    }
//                    .listRowSpacing(10)
                    //            .onChange(of: selectedWorkout) { _ in
                    //                save(key: "ExampleUser/SelectedWorkout", data: selectedWorkout)
                    //            }
                    
                    Spacer()
                    
                    
                    NavigationLink(destination: EmptyView()) {
                        
                    }
                    
                    if let foundDisplay = activeWorkoutInfo.display {
                        NavigationLink(destination: ActiveWorkoutView(workoutDisplay: foundDisplay)) {
                            HStack {
                                Text("Continue Workout")
                                Image(systemName: "arrow.right")
                            }
                            .font(.title2)
                            .foregroundColor(Color(.text))
                            .bold()
                            .ignoresSafeArea(.all)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color(.accent))
                            .overlay(Rectangle()
                                .stroke(Color(.darkGray).opacity(0.3), lineWidth: 4))
                            .padding(.vertical, 20)
                            
                        }
                    } else {
                        if selectedWorkout != nil {
                            
                            NavigationLink(destination: ActiveWorkoutView(workout: selectedWorkout!)) {
                                HStack {
                                    Text("Begin Workout")
                                    Image(systemName: "arrow.right")
                                }
                                    .font(.title2)
                                    .foregroundColor(Color(.text))
                                    .bold()
                                    .frame(width: UIScreen.main.bounds.width/1.6, height: 50)
                                    .background(Color(.accent))
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.darkGray).opacity(0.4), lineWidth: 4))
                                    .padding(.vertical, 40)
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


