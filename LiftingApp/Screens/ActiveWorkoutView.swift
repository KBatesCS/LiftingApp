//
//  ActiveWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/15/24.
//

import SwiftUI
import Combine

struct ActiveWorkoutView: View {
    @EnvironmentObject var routineList: RoutineList
    @EnvironmentObject var recordList: RecordList
    @Environment(\.sizeCategory) var sizeCategory
    @ObservedObject private var workoutDisplay: ActiveWorkoutDisplay
    @State private var timerString = "00:00:00"
    @State private var activeNotes: String = ""
    private var workoutName: String
    
    @State private var startTime = Date()
    @State private var elapsedTime = TimeInterval(0)
    @State private var timer: Timer?
    
    var elapsedTimeString: String {
            let currentTimeInterval = elapsedTime
            let hours = Int(currentTimeInterval / 3600)
            let minutes = Int((currentTimeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
            let seconds = Int(currentTimeInterval.truncatingRemainder(dividingBy: 60))
            
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    @FocusState var numPadFocus: Bool
    
    init(workout: Workout) {
        self.workoutName = workout.name
        self.workoutDisplay = ActiveWorkoutDisplay(workoutID: workout.id)
        
        for eSet in workout.exercises {
            let newESD = ActiveExerciseSetDisplay(exercise: eSet.exerciseInfo, intensityForm: eSet.intensityForm, inLBs: true)
            for set in eSet.sets {
                newESD.sets.append(ActiveSetDisplay(targetReps: set.reps, intensity: set.intensity))
            }
            self.workoutDisplay.exercises.append(newESD)
        }
    }
    
    
    var body: some View {
        HStack {
            Spacer()
            Text(workoutName)
                .scaledToFill()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Spacer()
            
            Text("\(elapsedTimeString)")
            
            Spacer()
             
        }
        
        Spacer()
        
        List {
            ForEach(workoutDisplay.exercises.indices, id: \.self) { woIndex in
                let eSetDisplay = workoutDisplay.exercises[woIndex]
                Section {
                    let displayIntensity = (eSetDisplay.intensityForm != IntensityType.None
                                            && !allSameIntensity(exerciseSet: eSetDisplay))
                    //Column headers
                    HStack {
                        Text("Target \nReps")
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        Spacer()
                        if displayIntensity {
                            Text(eSetDisplay.intensityForm == IntensityType.RPE ? "RPE" : "%1RPM")
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            Spacer()
                        }
                        Text("Reps")
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        Spacer()
                        Text("Weight")
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        Spacer()
                        RoundedRectangle(cornerRadius: 5.0)
                            .stroke(Color.clear, lineWidth: 2)
                            .frame(width: 25, height: 25, alignment: .leading)
                    }
                    
                    ForEach(eSetDisplay.sets.indices, id: \.self) { sindex in
                        let set = workoutDisplay.exercises[woIndex].sets[sindex]
                        //each row
                        HStack {
                            Text("\(set.targetReps)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .bold()
                            Spacer()
                            if displayIntensity {
                                Text("\(set.intensity)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .bold()
                                Spacer()
                            }
                            TextField("0", value: $workoutDisplay.exercises[woIndex].sets[sindex].achievedReps, format: .number)
                                .keyboardType(.numberPad)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            TextField("0", value: $workoutDisplay.exercises[woIndex].sets[sindex].weight, format: .number)
                                .keyboardType(.numberPad)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 5.0)
                                .stroke(lineWidth: 2)
                                .frame(width: 25, height: 25, alignment: .leading)
                                .cornerRadius(5.0)
                                .overlay {
                                    Image(systemName: self.workoutDisplay.exercises[woIndex].sets[sindex].completed ? "checkmark" : "")
                                }
                                .onTapGesture {
                                    self.workoutDisplay.exercises[woIndex].sets[sindex].completed.toggle()
                                    self.workoutDisplay.objectWillChange.send()
                                }
                            
                        }
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea(.all)
                    }
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(.all)
                } header: {
                    HStack {
                        Text(eSetDisplay.exercise.name)
                            .font(.system(size: 18))
                            .bold()
                            .frame(alignment: .leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // IF ALL EXERCISES ARE SAME INTENSITY, NO NEED FOR A NEW COLUMN
                        if (eSetDisplay.intensityForm != IntensityType.None
                            && allSameIntensity(exerciseSet: eSetDisplay)) {
                            if (eSetDisplay.intensityForm == IntensityType.RPE) {
                                Text("@ RPE \(eSetDisplay.sets[0].intensity)")
                                    .frame(alignment: .leading)
                                    .bold()
                                    .font(.system(size: 15))
                            } else {
                                Text("@ \(eSetDisplay.sets[0].intensity)% 1RPM")
                                    .frame(alignment: .leading)
                                    .bold()
                                    .font(.system(size: 15))
                            }
                        }
                        Spacer()
                        Picker("", selection: $workoutDisplay.exercises[woIndex].inLBs) {
                            Text("LBs").tag(true)
                            Text("KGs").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 100, alignment: .trailing)
                    }
                }
            }
            Section {
                TextField("Notes for next time", text: $activeNotes, axis: .vertical)
                    .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
                    .lineLimit(nil)
                
                
            } header: {
                Text("Notes")
                    .font(.system(size: 18))
                    .bold()
                    .frame(alignment: .leading)
            }
            Color(.clear)
                .frame(height: 1)
                .listRowBackground(Color.clear)
            
        }
        .scrollDismissesKeyboard(.interactively)
        .overlay {
            Spacer()
            Button (action: {
                //stopTimer()
            }, label: {
                Text("Finish Workout")
                    .frame(alignment: .bottom)
                    .font(.title2)
                    .foregroundColor(Color("Text"))
                    .bold()
                    .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
                    .background(Color("Accent"))
                    .cornerRadius(21)
                    .padding(.bottom, 6)
            })
            .frame(maxHeight: .infinity, alignment: .bottom)
            //  }
            
            
            // }
        }
        .onAppear {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.elapsedTime = Date().timeIntervalSince(startTime)
                if (self.elapsedTime >= 864999) { // should stop the timer right before 10 days hits.
                    self.timer?.invalidate()
                }
            }
        }
        .onDisappear {
                    self.timer?.invalidate()
        }
    }
    /*
    func stopTimer() {
        self.timer.upstream.connect().cancel()
        self.isTimerRunning = false
    }
    
    func startTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        self.isTimerRunning = true
    }*/
    
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
        let out = ActiveWorkoutDisplay(workoutID: workout.id)
        for eSet in workout.exercises {
            let newESD = ActiveExerciseSetDisplay(exercise: eSet.exerciseInfo, intensityForm: eSet.intensityForm, inLBs: true)
            newESD.sets = getDisplaySet(eset: eSet)
            out.exercises.append(newESD)
        }
        return out
    }
    
    func saveToRecord(displayInfo: ActiveWorkoutDisplay) {
        let workoutRecord = WorkoutRecord(userID: "ExampleUser", notes: activeNotes)
        for esetDisplay in workoutDisplay.exercises {
            let esetRecord: ExerciseRecord = ExerciseRecord(exercise: esetDisplay.exercise)
            esetRecord.inLBs = esetDisplay.inLBs
            for set in esetDisplay.sets {
                let achievedReps: Int = Int((set.achievedReps != nil) ? set.achievedReps! : 0)
                let weight: Double = (set.weight != nil) ? set.weight! : 0.0
                let setRecord: SetRecord = SetRecord(reps: achievedReps, weight: weight, completed: set.completed)
                esetRecord.sets.append(setRecord)
            }
            workoutRecord.exercises.append(esetRecord)
        }
        recordList.workoutRecords.append(workoutRecord)
        recordList.save()
        
    }
    
    func allExercisesComplete(displayInfo: ActiveWorkoutDisplay) -> Bool {
        for esetDisplay in workoutDisplay.exercises {
            for set in esetDisplay.sets {
                if !set.completed {
                    return false
                }
            }
        }
        return true
    }
}

class ActiveWorkoutDisplay: Identifiable, ObservableObject {
    let id = UUID()
    @Published var workoutID: UUID?
    @Published var exercises: [ActiveExerciseSetDisplay] = []
    
    init (workoutID: UUID?) {
        self.workoutID = workoutID
    }
}

class ActiveExerciseSetDisplay: Identifiable, ObservableObject {
    let id = UUID()
    @Published var exercise: Exercise
    @Published var intensityForm: IntensityType
    @Published var sets: [ActiveSetDisplay] = []
    @Published var inLBs: Bool
    
    init(exercise: Exercise, intensityForm: IntensityType, inLBs: Bool) {
        self.exercise = exercise
        self.intensityForm = intensityForm
        self.inLBs = inLBs
    }
}

class ActiveSetDisplay: Identifiable, ObservableObject {
    let id = UUID()
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
