//
//  SelectNewWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/4/24.
//

import SwiftUI

struct ChooseExerciseView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    //@EnvironmentObject var routineList: RoutineList
    
    private var exerciseList: [Exercise] = []
    
    var selectedExercise: Binding<Exercise?>
    
    init(selectedExercise: Binding<Exercise?>) {
        self.selectedExercise = selectedExercise
        self.exerciseList = getExercises()
    }
    
    var body: some View {

        
        List(Array(exerciseList.enumerated()), id: \.element.id) { index, exercise in
            exerciseDisplay(exercise: exercise)
                .onTapGesture {
                    selectedExercise.wrappedValue = exercise
                    presentationMode.wrappedValue.dismiss()
                    
                }
        }
    }
}

struct exerciseDisplay: View {
    var exercise: Exercise
    
    var body: some View {
        Text(exercise.name)
            .contentShape(Rectangle())
    }
}

struct SelectNewWorkoutPreview: PreviewProvider {
    static var previews: some View {
        let temp: Exercise? = nil
        return ChooseExerciseView(selectedExercise: .constant(temp))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
