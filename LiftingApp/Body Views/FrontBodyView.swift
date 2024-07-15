//
//  BodyView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 7/11/24.
//

import SwiftUI

struct FrontBodyView: View {
    @State public var chestColor: Color?
    @State public var frontDeltColor: Color?
    @State public var bicepColor: Color?
    @State public var abductorColor: Color?
    @State public var absColor: Color?
    @State public var adductorColor: Color?
    @State public var calvesColor: Color?
    @State public var forearmColor: Color?
    @State public var latsColor: Color?
    @State public var obliqueColor: Color?
    @State public var quadColor: Color?
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
                Image("f-outline")
                    .resizable()
                    .renderingMode(.template)
                
                if let chestColor = self.chestColor {
                    Image("f-pecs")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(chestColor)
                }
                if let absColor = self.absColor {
                    Image("f-abs")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(absColor)
                }
                if let frontDeltColor = self.frontDeltColor {
                    Image("f-front-delts")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(frontDeltColor)
                }
                if let bicepColor  = self.bicepColor {
                    Image("f-biceps")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(bicepColor)
                }
                if let adductorColor = self.adductorColor {
                    Image("f-adductors")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(adductorColor)
                }
                if let calvesColor = self.calvesColor {
                    Image("f-calves")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(calvesColor)
                }
                if let forearmColor = self.forearmColor {
                    Image("f-forearms")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(forearmColor)
                }
                if let latsColor = self.latsColor {
                    Image("f-lats")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(latsColor)
                }
                if let obliqueColor = self.obliqueColor {
                    Image("f-obliques")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(obliqueColor)
                }
                if let quadColor = self.quadColor {
                    Image("f-quads")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(quadColor)
                }
                if let trapColor = self.trapColor {
                    Image("f-traps")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(trapColor)
                }
                if let tricepColor = self.tricepColor {
                    Image("f-triceps")
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
        self.chestColor = nil
        self.frontDeltColor = nil
        self.bicepColor = nil
        self.abductorColor = nil
        self.absColor = nil
        self.adductorColor = nil
        self.calvesColor = nil
        self.forearmColor = nil
        self.latsColor = nil
        self.obliqueColor = nil
        self.quadColor = nil
        self.trapColor = nil
        self.tricepColor = nil
    }
    
    func setColors(muscles: [Muscles], color: Color) {
        for muscle in muscles {
            switch muscle {
            case Muscles.chest:
                self.chestColor = color
            case Muscles.adductor:
                self.adductorColor = color
            case Muscles.abdominal:
                self.absColor = color
            case Muscles.bicep:
                self.bicepColor = color
            case Muscles.calf:
                self.calvesColor = color
            case Muscles.forearmflexor:
                self.forearmColor = color
            case Muscles.forearmextensor:
                self.forearmColor = color
            case Muscles.frontdeltoid:
                self.frontDeltColor = color
            case Muscles.lat:
                self.latsColor = color
            case Muscles.oblique:
                self.obliqueColor = color
            case Muscles.quad:
                self.quadColor = color
            case Muscles.trapezius:
                self.trapColor = color
            case Muscles.tricep:
                self.tricepColor = color
            case Muscles.shoulder:
                self.frontDeltColor = color
            default: break
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
        self.exercise = loadExercise(uuid: UUID(uuidString: "38AB262B-F0B3-4778-A230-92179E3F91CE"))
    }
    
    var body: some View {
        FrontBodyView(exercise: $exercise)
    }
}


struct BodyViewPreview: PreviewProvider {
    static var previews: some View {
        return BVPreviewView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
