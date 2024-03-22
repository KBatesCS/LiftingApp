//
//  EditWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/21/24.
//

import SwiftUI

struct EditWorkoutView: View {
    //@Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var routineList: RoutineList
    @ObservedObject var workout: Workout
    
    init (workout: Workout) {
        self.workout = workout
    }
    
    var body: some View {
        VStack {
            
            TextField("name", text: $workout.name)
                .textFieldStyle(RoundedTextFieldStyle())
                .frame(alignment: .topLeading)
                .padding()
                .onChange(of: workout.name) { _ in
                    routineList.refreshAndSave()
                }
            Spacer()
            
            /*
            List(Array(workout.exercises.enumerated()), id: \.element.id) { index, eset in
                if let data = UserDefaults.standard.data(forKey: workout.exercises[index].id.uuidString) {
                    if let loadedESet = try? JSONDecoder().decode(ExerciseSet.self, from: data) {
                        NavigationLink(destination: SelectNewWorkoutView(workout: workout, eSet: loadedESet)) {
                            ExerciseSetDisplay(eset: loadedESet)
                        }
                    }
                }
            }
            */
            
            List(workout.exercises, id: \.self) { exerciseSet in
                ExerciseSetDisplay(workout: workout, eset: exerciseSet)
            }
            //.listRowSpacing(10)
             
            Spacer()
            
            NavigationLink(destination: SelectNewWorkoutView(workout: workout, eSet: nil)) {
                Text("+ exersize")
                    .font(.title2)
                    .foregroundColor(Color("Background"))
                    .bold()
            }
            
            Spacer()
        }
        /*
        .onAppear {
            if (self.isNew) {
                self.routine.addWorkout(newWorkout: self.workout)
            }
            self.name = self.workout.name
        }
         */
    }
}
struct ExerciseSetDisplay: View {
    @EnvironmentObject var routineList: RoutineList
    @ObservedObject var workout: Workout
    @ObservedObject var eset: ExerciseSet
    
    var body: some View {
        Section {
                let displayIntensity = eset.intensityForm != IntensityType.None
                ForEach(eset.sets.indices, id: \.self) { index in
                    let curSet = eset.sets[index]
                    HStack {
                        Text("Set \(index):")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Spacer()
                        
                        if displayIntensity {
                            TextField("0", value: $eset.sets[index].intensity, format: .number)
                                .keyboardType(.numberPad)
                                .onChange(of: eset.sets[index].intensity) { _ in
                                    routineList.refreshAndSave()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                        }
                        Spacer()
                        HStack {
                            Button(action: {
                                if curSet.reps >= 1 {
                                    curSet.reps -= 1
                                    routineList.refreshAndSave()
                                }
                            }) {
                                Text("-")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Text("\(curSet.reps)")
                            
                            Button(action: {
                                curSet.reps += 1
                                routineList.refreshAndSave()
                            }) {
                                Text("+")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    //.padding(.horizontal) // Add horizontal padding for better spacing
                }
                .foregroundColor(Color("Text"))
                //.listRowBackground(Color("Accent"))
            
        } header: {
            HStack {
                NavigationLink(destination: SelectNewWorkoutView(workout: workout, eSet: eset)) {
                    Text(eset.exerciseInfo.name)
                        .foregroundStyle(Color("Text"))
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                Spacer()
                Picker("", selection: $eset.intensityForm) {
                    Text("RPE").tag(IntensityType.RPE)
                    Text("None").tag(IntensityType.None)
                    Text("%RPM").tag(IntensityType.PercentOfMax)
                }
                .pickerStyle(.segmented)
                .onChange(of: eset.intensityForm) { _ in
                    routineList.refreshAndSave()
                }
            }
        }
    }
}
/*
 #Preview {
 EditWorkoutView(routine: Routine(), workout: Workout())
 }
 */
