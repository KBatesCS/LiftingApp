//
//  ActiveWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/15/24.
//

import SwiftUI

struct ActiveWorkoutView: View {
    @EnvironmentObject var routineList: RoutineList
    @Environment(\.sizeCategory) var sizeCategory
    @ObservedObject var workout: Workout
    @State var workoutDisplay: ActiveWorkoutDisplay = ActiveWorkoutDisplay(workoutID: nil)
    @State private var startTime = Date()
    @State private var timerString = "00:00:00"
    @State private var isTimerRunning = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var workoutRecord: WorkoutRecord = WorkoutRecord(userID: "ExampleUser", date: Date())
    
    @State private var temp: Double?
    @FocusState var numPadFocus: Bool
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea(.container, edges: .top)
            
            // TITLE/TOP OF SCREEN
            VStack {
                HStack {
                    Spacer()
                    Text(workout.name)
                        .scaledToFill()
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Spacer()
                    Text("\(timerString)")
                        .onReceive(timer) { _ in
                            if self.isTimerRunning {
                                self.timerString = hhmmssTimeSince(date: self.startTime)
                            }
                        }
                    Spacer()
                }
                .onAppear {
                    if !isTimerRunning {
                        startTime = Date()
                        startTimer()
                    }
                }
                
                Spacer()
                GeometryReader { geometry in
                    ScrollView {
                        ForEach(workoutDisplay.exercises.indices, id: \.self) { woIndex in
                            var eSetDisplay = workoutDisplay.exercises[woIndex]
                            Section {
                                HStack {
                                    Text("target")
                                        .frame(width: geometry.size.width / 4, alignment: .leading)
                                    Text("intensity")
                                        .frame(width: geometry.size.width / 4, alignment: .leading)
                                    Text("reps")
                                        .frame(width: geometry.size.width / 4, alignment: .leading)
                                    Text("weight")
                                        .frame(width: geometry.size.width / 4, alignment: .leading)
                                }
                                
                                ForEach(eSetDisplay.sets.indices, id: \.self) { sindex in
                                    var set = eSetDisplay.sets[sindex]
                                        //var setRecord :
                                    HStack {
                                        Text("\(set.targetReps)")
                                            .frame(width: geometry.size.width / 4, alignment: .leading)
                                        Text("\(set.intensity)")
                                            .frame(width: geometry.size.width / 4, alignment: .leading)
                                        TextField("0", value: $workoutDisplay.exercises[woIndex].sets[sindex].achievedReps, format: .number)
                                            .keyboardType(.numberPad)
                                            .frame(width: geometry.size.width / 4, alignment: .leading)
                                        TextField("0", value: $workoutDisplay.exercises[woIndex].sets[sindex].weight, format: .number)
                                            .keyboardType(.numberPad)
                                            .frame(width: geometry.size.width / 4, alignment: .leading)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .ignoresSafeArea(.all)
                                }
                            } header: {
                                Text(eSetDisplay.exercise.name)
                                    .scaleEffect(1.0)
                                    .bold()
                                    .frame(alignment: .leading)
                                // IF ALL EXERCISES ARE SAME INTENSITY, NO NEED FOR A NEW COLUMN
                                if (eSetDisplay.intensityForm != IntensityType.None
                                    && allSameIntensity(exerciseSet: eSetDisplay)) {
                                    if (eSetDisplay.intensityForm == IntensityType.RPE) {
                                        Text("@ RPE \(eSetDisplay.sets[0].intensity)")
                                    } else {
                                        Text("@ \(eSetDisplay.sets[0].intensity)% 1RPM")
                                    }
                                }
                            }
                            .frame(width: geometry.size.width, alignment: .leading)
                            .listSectionSeparator(.hidden, edges: .bottom)
                            
                        }
                    }
                    //.environment(\.sizeCategory, .large)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(.all)
                }
                
                
                
                Spacer()
                Button (action: {
                    stopTimer()
                }, label: {
                    Text("Finish Workout")
                        .frame(alignment: .bottom)
                        .font(.title2)
                        .foregroundColor(Color("Text"))
                        .bold()
                        .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
                        .background(Color("Accent"))
                        .cornerRadius(21)
                        .padding()
                })
                
            }
        }
        .onAppear {
            if workoutDisplay.workoutID == nil {
                self.workoutDisplay = getActiveWorkoutDisplay(workout: workout)
            }
        }
    }
    
    func stopTimer() {
        self.timer.upstream.connect().cancel()
        self.isTimerRunning = false
    }
    
    func startTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        self.isTimerRunning = true
    }
    
    func allSameIntensity(exerciseSet: ActiveExerciseSetDisplay) -> Bool{
        if (!exerciseSet.sets.isEmpty) {
            let firstIntensity = exerciseSet.sets[0].intensity
            for index in 0..<exerciseSet.sets.count {
                if exerciseSet.sets[index].intensity != firstIntensity {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    func hhmmssTimeSince(date: Date) -> String {
        let currentTimeInterval = Date().timeIntervalSince(date)
        let hours = Int(currentTimeInterval / 3600)
        let minutes = Int((currentTimeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(currentTimeInterval.truncatingRemainder(dividingBy: 60))

        let out = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
        return out
    }
    
    func getDisplaySet(eset: ExerciseSet) -> [ActiveSetDisplay]{
        var out: [ActiveSetDisplay] = []
        
        for set in eset.sets {
            out.append(ActiveSetDisplay(targetReps: set.reps, intensity: set.intensity))
        }
        
        return out
    }
    
    func getActiveWorkoutDisplay(workout: Workout) -> ActiveWorkoutDisplay {
        var out = ActiveWorkoutDisplay(workoutID: workout.id)
        for eSet in workout.exercises {
            var newESD = ActiveExerciseSetDisplay(exercise: eSet.exerciseInfo, intensityForm: eSet.intensityForm)
            newESD.sets = getDisplaySet(eset: eSet)
            out.exercises.append(newESD)
        }
        return out
    }
}

class ActiveWorkoutDisplay: Identifiable, ObservableObject {
    @Published var workoutID: UUID?
    @Published var exercises: [ActiveExerciseSetDisplay] = []
    
    init (workoutID: UUID?) {
        self.workoutID = workoutID
    }
}

class ActiveExerciseSetDisplay: Identifiable, ObservableObject {
    @Published var exercise: Exercise
    @Published var intensityForm: IntensityType
    @Published var sets: [ActiveSetDisplay] = []
    
    init(exercise: Exercise, intensityForm: IntensityType) {
        self.exercise = exercise
        self.intensityForm = intensityForm
    }
}

class ActiveSetDisplay: Identifiable, ObservableObject {
    @Published var targetReps: Int
    @Published var intensity: Int
    @Published var achievedReps: Double?
    @Published var weight: Double?
    @Published var completed: Bool = false
    
    
    init(targetReps: Int, intensity: Int, achievedReps: Double? = nil, weight: Double? = nil) {
        self.targetReps = targetReps
        self.intensity = intensity
        self.achievedReps = achievedReps
        self.weight = weight
    }
}

/*
#Preview {
    ActiveWorkoutView()
}
*/
