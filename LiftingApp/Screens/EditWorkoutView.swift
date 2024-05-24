//
//  EditWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/21/24.
//

import SwiftUI

struct EditWorkoutView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var workout: CDWorkout
    @State var newExercise: Exercise? = nil
    
    init (workout: CDWorkout) {
        self.workout = workout
    }
    
    var body: some View {
        VStack {
            
            TextField("name", text: $workout.name)
                .textFieldStyle(RoundedTextFieldStyle())
//                .frame(alignment: .topLeading)
                .foregroundStyle(Color(.text))
                .onChange(of: workout.name) { _ in
                    workout.routine?.objectWillChange.send()
                }
                .padding()
                .overlay(Image(systemName: "square.and.pencil").frame(maxWidth: .infinity, alignment: .trailing).padding(.trailing, 22).foregroundStyle(Color(.text)))
            
            Spacer()
            
            List {
                ForEach(workout.exercises, id: \.self) { exerciseSet in
                    ExerciseSetDisplay(eset: exerciseSet)
                }
                Text("")
                    .listRowBackground(Color.clear)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            
            
            Spacer()
        }
        .overlay {
            NavigationLink(destination: SelectNewWorkoutView(selectedExercise: $newExercise)) {
                Text("+ exersize")
                    .accentedButtonTextStyle()
            }
            .accentedButtonStyle()
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 15)
            .onChange(of: newExercise) { _ in
                if newExercise != nil {
                    let newESet = CDExerciseSet(exercise: newExercise!, orderLoc: workout.exercises.count + 1, context: context)
                    let newSet1 = CDSet(targetReps: "12", intensity: 0, orderLoc: 1, context: context)
                    let newSet2 = CDSet(targetReps: "12", intensity: 0, orderLoc: 2, context: context)
                    let newSet3 = CDSet(targetReps: "12", intensity: 0, orderLoc: 3, context: context)
                    newESet.sets.append(newSet1)
                    newESet.sets.append(newSet2)
                    newESet.sets.append(newSet3)
                    workout.exercises.append(newESet)
                    newExercise = nil
                }
            }
        }
    }
}
struct ExerciseSetDisplay: View {
    @ObservedObject var eset: CDExerciseSet
    @Environment(\.managedObjectContext) var context
    @State var newExercise: Exercise? = nil
    
    var body: some View {
        Section {
            let displayIntensity = eset.intensityType != IntensityType.None
            
            HStack {
                Text("Set #")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                if eset.intensityType == IntensityType.RPE {
                    Text("RPE")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                } else if eset.intensityType == IntensityType.PercentOfMax {
                    Text("%RPM")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                Text("Target Reps")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ForEach(eset.sets, id: \.self) { set in
                SetEditRow(set: set, displayIntensity: displayIntensity)
                
            }
            .onDelete(perform: { indexSet in
                eset.sets.remove(atOffsets: indexSet)
                for (index, element) in eset.sets.enumerated() {
                    element.orderLoc = index + 1
                }
            })
            HStack {
                Text("+ set")
                    .onTapGesture {
                        let targetReps = eset.sets.last?.targetReps ?? "12"
                        let intensity = eset.sets.last?.intensity ?? 0.0
                        eset.sets.append(CDSet(targetReps: targetReps, intensity: intensity, orderLoc: eset.sets.count + 1, context: context))
                    }
                    .foregroundStyle(Color(.text))
                    .bold()
                    .frame(maxWidth: .infinity, maxHeight: 25)
                    .background(Color(.gray))
                    .cornerRadius(6)
                
                Divider().frame(width: 3, height: 30) // Vertical line
                
                Text("rest: ")
                
                TextField("0", value: $eset.restLength, format: .number)
                    .frame(width: 40) // Adjust width as needed
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                
                Text("seconds")
            }
            
            
            
            
            
            
        } header: {
            HStack {
                
                NavigationLink(destination: SelectNewWorkoutView(selectedExercise: $newExercise)) {
                    Text(eset.exercise.name)
                        .foregroundStyle(Color("Text"))
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                }
                .onChange(of: newExercise) { _ in
                    if newExercise != nil {
                        eset.exercise = newExercise!
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                Picker("", selection: $eset.intensityType) {
                    Text("RPE").tag(IntensityType.RPE)
                    Text("None").tag(IntensityType.None)
                    Text("%RPM").tag(IntensityType.PercentOfMax)
                }
                .pickerStyle(.segmented)
            }
        }
        
    }
}

struct SetEditRow: View {
    @ObservedObject var set: CDSet
    var displayIntensity: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Set \(set.orderLoc):")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                if displayIntensity {
                    TextField("0", value: $set.intensity, format: .number)
                        .keyboardType(.numberPad)
                }
                
                Spacer()
                
                TextField("0", text: $set.targetReps.max(5))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .scrollDismissesKeyboard(.interactively)
            }
        }
    }
}

struct ewPreviewView: View {
    @FetchRequest(fetchRequest: CDWorkout.fetch())
    var workouts: FetchedResults<CDWorkout>
    
    @State var workout: CDWorkout?
    
    init() {
        let request = CDWorkout.fetch()
        _workouts = FetchRequest(fetchRequest: request)
    }
    var body: some View {
        VStack {
            if workout != nil {
                EditWorkoutView(workout: workout!)
            }
        } .onAppear {
            workout = workouts[0]
        }
    }
}

struct EditWorkoutPreview: PreviewProvider {
    static var previews: some View {
        return ewPreviewView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


