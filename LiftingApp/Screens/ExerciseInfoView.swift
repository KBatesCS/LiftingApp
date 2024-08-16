//
//  ExerciseInfoView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 5/24/24.
//

import SwiftUI

struct ExerciseInfoView: View {
    private var selectedExerciseWrapped: Binding<Exercise>
    private var selectedExercise: Exercise
    
    private var allExercises: [Exercise]
    
    init(with selectedExerciseWrapped: Binding<Exercise>) {
        self.selectedExerciseWrapped = selectedExerciseWrapped
        self.selectedExercise = selectedExerciseWrapped.wrappedValue
        self.allExercises = getExercises()
    }
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                Text(selectedExercise.name)
                    .frame(alignment: .leading)
                    .padding(.top, 20)
                    .padding()
                    .font(.system(size: 25))
                    .bold()
                
                Text("How to perform")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .opacity(0.8)
                    .bold()
                
                if selectedExercise.desc != "" {
                    Text(selectedExercise.desc)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accentedSectionBodyStyle()
                        .padding(.horizontal, 10)
                }
                HStack {
                    FrontBodyView(exercise: selectedExerciseWrapped)
                        .aspectRatio(contentMode: .fit)
                    BackBodyView(exercise: selectedExerciseWrapped)
                        .aspectRatio(contentMode: .fit)
                }
                .padding(.horizontal, 20)
                HStack {
                    VStack {
                        Text("Primary Muscles")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 10)
                            .opacity(0.8)
                            .bold()
                        VStack {
                            ForEach(selectedExercise.primaryMusclesWorked, id: \.self) { muscle in
                                Text("- \(muscle.rawValue)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accentedSectionBodyStyle()
                        .padding(.horizontal, 10)
                    }
                    VStack {
                        Text("Secondary Muscles")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 10)
                            .opacity(0.8)
                            .bold()
                        VStack {
                            ForEach(selectedExercise.secondaryMusclesWorked, id: \.self) { muscle in
                                Text("- \(muscle.rawValue)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accentedSectionBodyStyle()
                        .padding(.horizontal, 10)
                    }
                }
                .padding(.vertical, 10)
                
                NavigationLink(destination: ReplaceExerciseView(with: selectedExerciseWrapped)) {
                    Text("Replace Exercise")
                        .accentedButtonTextStyle()
                        .accentedButtonStyle()
                }
                Spacer()
            }}
        
    }
}

struct EIPreviewView: View {
    
    @FetchRequest(fetchRequest: CDWorkoutRecord.fetch())
    var workouts: FetchedResults<CDWorkoutRecord>
    
    //    @State var workoutRecord: CDWorkoutRecord? = nil
    @State var exercise: Exercise = loadExercise(uuid: UUID(uuidString: "5461CEE3-F61F-4738-B230-9AF06964EB9F"))
    @State var showSheet = true
    
    
    init() {
        let request = CDWorkoutRecord.fetch()
        _workouts = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack {
            Text("hi")
        }
        .sheet(isPresented: $showSheet) {
            ExerciseInfoView(with: $exercise)
        }
    }
}


struct ExerciseInfoViewPreview: PreviewProvider {
    static var previews: some View {
        return EIPreviewView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
