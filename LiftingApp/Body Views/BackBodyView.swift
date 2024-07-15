//
//  BodyView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 7/11/24.
//

import SwiftUI

struct BackBodyView: View {
    @State public var backDeltColor: Color?
    @State public var calfColor: Color?
    @State public var forearmColor: Color?
    @State public var gluteColor: Color?
    @State public var hamestringColor: Color?
    @State public var latColor: Color?
    @State public var lowerBackColor: Color?
    @State public var trapColor: Color?
    @State public var tricepColor: Color?
    private let primaryMuscleColor = Color(.red)
    private let secondaryMuscleColor = Color(.red).opacity(0.5)
    private var selectedExerciseWrapped: Binding<Exercise>
    @State private var exercise: Exercise
//    init() {}
    
    init(exercise: Binding<Exercise>) {
        self.selectedExerciseWrapped = exercise
        self.exercise = selectedExerciseWrapped.wrappedValue
    }
    
    var body: some View {
        VStack {
            
            ZStack {
                Image("b-outline")
                    .resizable()
                    .renderingMode(.template)
                
                if let backDeltColor = self.backDeltColor {
                    Image("b-back-delts")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(backDeltColor)
                }
                if let calfColor = self.calfColor {
                    Image("b-cavles")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(calfColor)
                }
                if let forearmColor = self.forearmColor {
                    Image("b-forearms")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(forearmColor)
                }
                if let gluteColor  = self.gluteColor {
                    Image("b-glutes")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(gluteColor)
                }
                if let hamestringColor = self.hamestringColor {
                    Image("b-hamstrings")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(hamestringColor)
                }
                if let latColor = self.latColor {
                    Image("b-lats")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(latColor)
                }
                if let lowerBackColor = self.lowerBackColor {
                    Image("b-lower-back")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(lowerBackColor)
                }
                if let trapColor = self.trapColor {
                    Image("b-traps")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(trapColor)
                }
                if let tricepColor = self.tricepColor {
                    Image("b-triceps")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(tricepColor)
                }
            }
             
        }
        .onChange(of: selectedExerciseWrapped.wrappedValue) { _ in
            resetColors()
            exercise = selectedExerciseWrapped.wrappedValue
            setColors(muscles: exercise.primaryMusclesWorked, color: primaryMuscleColor)
            
            setColors(muscles: exercise.secondaryMusclesWorked, color: secondaryMuscleColor)
        }
        .onAppear {
            exercise = selectedExerciseWrapped.wrappedValue
            setColors(muscles: exercise.primaryMusclesWorked, color: primaryMuscleColor)
            
            setColors(muscles: exercise.secondaryMusclesWorked, color: secondaryMuscleColor)
                }
    }
    
    func resetColors() {
        self.backDeltColor = nil
        self.calfColor = nil
        self.forearmColor = nil
        self.gluteColor = nil
        self.hamestringColor = nil
        self.latColor = nil
        self.lowerBackColor = nil
        self.trapColor = nil
        self.tricepColor = nil
    }
    
    func setColors(muscles: [Muscles], color: Color) {
        for muscle in muscles {
            switch muscle {
            case Muscles.reardeltoid:
                self.backDeltColor = color
            case Muscles.calf:
                self.calfColor = color
            case Muscles.forearmflexor:
                self.forearmColor = color
            case Muscles.forearmextensor:
                self.forearmColor = color
            case Muscles.glute:
                self.gluteColor = color
            case Muscles.hamstring:
                self.hamestringColor = color
            case Muscles.lat:
                self.latColor = color
            case Muscles.lowback:
                self.lowerBackColor = color
            case Muscles.trapezius:
                self.trapColor = color
            case Muscles.tricep:
                self.tricepColor = color
            default: break
            }
        }
    }
    
}

struct BBPreviewView: View {
    
    @FetchRequest(fetchRequest: CDWorkoutRecord.fetch())
    var workouts: FetchedResults<CDWorkoutRecord>
    
    //    @State var workoutRecord: CDWorkoutRecord? = nil
    @State var exercise: Exercise
    @State var showSheet = true
    
    
    init() {
        self.exercise = loadExercise(uuid: UUID(uuidString: "38AB262B-F0B3-4778-A230-92179E3F91CE"))
    }
    
    var body: some View {
        BackBodyView(exercise: $exercise)
    }
}


struct BackBodyViewPreview: PreviewProvider {
    static var previews: some View {
        return BBPreviewView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
