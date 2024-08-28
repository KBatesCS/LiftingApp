//
//  CircledBodyView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 8/16/24.
//

import SwiftUI

struct CircledBodyView: View {
    
    @State var exercise: Exercise
    let area: Int = 0
    
    var radius = 0.0
    var x = 0
    var y = 0
    
    init(exercise: Exercise) {
        self.exercise = exercise
        
        self.radius = 200.0
    }
    
    var body: some View {
        GeometryReader { geometry in
            
        }
    }
}

struct CBPreviewView: View {
    
    @FetchRequest(fetchRequest: CDWorkoutRecord.fetch())
    var workouts: FetchedResults<CDWorkoutRecord>
    
    //    @State var workoutRecord: CDWorkoutRecord? = nil
    @State var exercise: Exercise
    @State var showSheet = true
    
    
    init() {
        self.exercise = loadExercise(uuid: UUID(uuidString: "24078134-D10B-4F0F-A706-E461A901FC7E"))
    }
    
    var body: some View {
        CircledBodyView(exercise: exercise)
    }
}


struct CircledBodyViewPreview: PreviewProvider {
    static var previews: some View {
        return CBPreviewView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
