//
//  ReplaceExerciseView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 6/5/24.
//

import SwiftUI

struct ReplaceExerciseView: View {
    private var selectedExerciseWrapped: Binding<Exercise>
    private var selectedExercise: Exercise
    
    private var allExercises: [Exercise]
    @State private var currentTab: Int = 1
    
    init(with selectedExerciseWrapped: Binding<Exercise>) {
        self.selectedExerciseWrapped = selectedExerciseWrapped
        self.selectedExercise = selectedExerciseWrapped.wrappedValue
        self.allExercises = getExercises()
    }
    
    var body: some View {
        VStack {
            Text("Replacing:\n \(selectedExercise.name)")
            
            TabView(selection: $currentTab,
                    content:  {
                recommendedExercises(with: selectedExerciseWrapped)
                    .tag(1)
                
                AllExercisesView(with: selectedExerciseWrapped)
                    .tag(2)
            })
            
            Spacer()
        }
        .padding()
        
            
    }
}

struct recommendedExercises: View {
    private var selectedExerciseWrapped: Binding<Exercise>
    private var selectedExercise: Exercise
    
    private var allExercises: [Exercise]
    @State private var recommendedExercises: [Exercise]? = nil
    
    init(with selectedExerciseWrapped: Binding<Exercise>) {
        self.selectedExerciseWrapped = selectedExerciseWrapped
        self.selectedExercise = selectedExerciseWrapped.wrappedValue
        self.allExercises = getExercises()
    }
    
    var body: some View {
        VStack {
            Text("hi")
            if let recommendedExercises = self.recommendedExercises {
                ForEach(recommendedExercises) { exercise in
                    Button(action: {
                        self.selectedExerciseWrapped.wrappedValue = exercise
                    }, label: {
                        Text("\(exercise.name)")
                    })
                }
            }
        }
        .onAppear {
            self.recommendedExercises = getRecommendedExercises(with: selectedExercise)
        }
    }
    
    func getRecommendedExercises(with selectedExercise: Exercise) -> [Exercise] {
        var scoredExercises: [(Exercise, Double)] = []
        
        // Calculate scores for each exercise
        for exercise in allExercises {
            if exercise == selectedExercise {
                continue
            }
            
            var score = 0.0
            for primaryMusclesWork in exercise.primaryMusclesWorked {
                if selectedExercise.primaryMusclesWorked.contains(primaryMusclesWork) {
                    score += 2.0
                } else if selectedExercise.secondaryMusclesWorked.contains(primaryMusclesWork) {
                    score += 1.0
                }
            }
            
            for secondaryMusclesWork in exercise.secondaryMusclesWorked {
                if selectedExercise.primaryMusclesWorked.contains(secondaryMusclesWork) {
                    score += 0.75
                } else if selectedExercise.secondaryMusclesWorked.contains(secondaryMusclesWork) {
                    score += 0.5
                }
            }
            
            if score > 2.0 {
                scoredExercises.append((exercise, score))
            }
        }
        
        // Sort the exercises based on their scores in descending order
        scoredExercises.sort { $0.1 > $1.1 }
        
        // Return the top 10 exercises with the highest scores
        let topExercises = scoredExercises.prefix(10).map { $0.0 }
        return Array(topExercises)
    }
}

struct AllExercisesView: View {
    private var selectedExerciseWrapped: Binding<Exercise>
    private var selectedExercise: Exercise
    
    private var allExercises: [Exercise]
    
    init(with selectedExerciseWrapped: Binding<Exercise>) {
        self.selectedExerciseWrapped = selectedExerciseWrapped
        self.selectedExercise = selectedExerciseWrapped.wrappedValue
        self.allExercises = getExercises()
    }
    
    var body: some View {
        VStack {
            Text("screen 2")
        }
    }
}

struct REPreviewView: View {
    
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
            ReplaceExerciseView(with: $exercise)
        }
    }
    
    
}


struct ReplaceExerciseViewPreview: PreviewProvider {
    static var previews: some View {
        return REPreviewView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

