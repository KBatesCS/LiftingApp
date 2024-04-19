//
//  StartWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/25/24.
//

import SwiftUI

struct StartWorkoutView: View {
    
    //@EnvironmentObject private var routineList: RoutineList
    @EnvironmentObject private var activeWorkoutInfo: ActiveWorkoutViewData
    
    @State private var selectedRoutine: CDWorkoutRoutine?
    
    @State private var selectedWorkout: CDWorkout?
    
    //@State private var isShowingActiveWorkout = false
//    @State private var activeViewHolder: ActiveWorkoutViewHolder
    //@State var currActiveWorkoutView: ActiveWorkoutView? = nil
    
    @FetchRequest(fetchRequest: CDWorkoutRoutine.fetch())
    var workoutRoutines: FetchedResults<CDWorkoutRoutine>
    
    init() {
        let request = CDWorkoutRoutine.fetch()
        self._workoutRoutines = FetchRequest(fetchRequest: request)
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
                    
                    if activeWorkoutInfo.workoutName == nil || activeWorkoutInfo.startTime == nil || activeWorkoutInfo.displayInfo == nil || activeWorkoutInfo.workoutID == nil {
                        
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
                    } else {
                        NavigationLink(destination: ActiveWorkoutView(workoutDisplay: activeWorkoutInfo.displayInfo!, startTime: activeWorkoutInfo.startTime!, workoutName: activeWorkoutInfo.workoutName!, workoutID: activeWorkoutInfo.workoutID!)) {
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
    @Published var workoutID: UUID?
    
    init(displayInfo: ActiveWorkoutDisplay? = nil, startTime: Date? = nil, workoutName: String? = nil, workoutID: UUID? = nil) {
        self.displayInfo = displayInfo
        self.startTime = startTime
        self.workoutName = workoutName
        self.workoutID = workoutID
    }
}


struct stwPreviewView: View {
    @StateObject private var activeWorkoutInfo: ActiveWorkoutViewData

    init() {
        _activeWorkoutInfo = StateObject(wrappedValue: ActiveWorkoutViewData())
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

