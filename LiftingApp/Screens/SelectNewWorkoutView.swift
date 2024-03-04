//
//  SelectNewWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/4/24.
//

import SwiftUI

struct SelectNewWorkoutView: View {
    @Binding var selectedExerciseUUID: Int
    private var exerciseList: [Exercise]
    
    init(selectedExerciseUUID: Int) {
        self.selectedExerciseUUID = selectedExerciseUUID
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    func getWorkouts() -> [Exercise] {
        
    }
}

#Preview {
    @State var uuid: Int = -1
    SelectNewWorkoutView(selectedExerciseUUID: uuid)
}
