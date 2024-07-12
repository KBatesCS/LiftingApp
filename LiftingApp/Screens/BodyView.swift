//
//  BodyView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 7/11/24.
//

import SwiftUI

struct BodyView: View {
    @State public var chestColor: Color?
    @State public var frontDeltColor: Color?
    private let primaryMuscleColor = Color(.red)
    private let secondaryMuscleColor = Color(.orange).opacity(0.6)
    @State private var test = "hello"
    @State private var exercise: Exercise
//    init() {}
    
    init(exercise: Exercise) {
        self.exercise = exercise
        test = exercise.name
        
    }
    
    var body: some View {
        VStack {
            
            ZStack {
                Image("Anatomy-front")
                    .renderingMode(.template)
                if let chestColor = self.chestColor {
                    Image("chest")
                        .renderingMode(.template)
                        .foregroundStyle(chestColor)
                }
                Image("abs")
                    .renderingMode(.template)
                    .foregroundStyle(Color(.orange))
                if let frontDeltColor = self.frontDeltColor {
                    Image("front-delts")
                        .renderingMode(.template)
                        .foregroundStyle(frontDeltColor)
                }
                
            }
            .aspectRatio(contentMode: .fit)
            .scaleEffect(CGSize(width: 0.25, height: 0.25))
             
        }
        .onAppear {
            let ex = loadExercise(uuid: UUID(uuidString: "2ABFB8CA-E493-4EC8-B04A-45FDDF7D92A4"))
            let primaryMuscles = ex.primaryMusclesWorked
            for muscle in primaryMuscles {
                if muscle == Muscles.chest {
                    self.chestColor = Color(.red)
                } else if muscle == Muscles.shoulder {
                    frontDeltColor = primaryMuscleColor
                }
            }
            self.chestColor = primaryMuscleColor
            
            let secondaryMuscles = exercise.secondaryMusclesWorked
            for muscle in exercise.secondaryMusclesWorked {
                if muscle == Muscles.chest {
                    chestColor = secondaryMuscleColor
                } else if muscle == Muscles.shoulder {
                    frontDeltColor = secondaryMuscleColor
                }
            }
        }
    }
}

struct BVPreviewView: View {
    
    @FetchRequest(fetchRequest: CDWorkoutRecord.fetch())
    var workouts: FetchedResults<CDWorkoutRecord>
    
    //    @State var workoutRecord: CDWorkoutRecord? = nil
    @State var exercise: Exercise
    @State var showSheet = true
    
    
    init() {
        self.exercise = loadExercise(uuid: UUID(uuidString: "2ABFB8CA-E493-4EC8-B04A-45FDDF7D92A4"))
    }
    
    var body: some View {
        BodyView(exercise: self.exercise)
    }
}


struct BodyViewPreview: PreviewProvider {
    static var previews: some View {
        return BVPreviewView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
