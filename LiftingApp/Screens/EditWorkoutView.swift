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
                NavigationLink(destination: SelectNewWorkoutView(workout: workout, eSet: exerciseSet)) {
                    ExerciseSetDisplay(eset: exerciseSet)
                }
            }
             
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
    
    let eset: ExerciseSet
    
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
            Text(eset.exerciseInfo.name)
            List(eset.repList.indices, id: \.self) { index in
                Text("Item \(eset.repList[index])")
            }
            .scrollDisabled(true)
        }
        .padding()
    }
}
/*
 #Preview {
 EditWorkoutView(routine: Routine(), workout: Workout())
 }
 */
