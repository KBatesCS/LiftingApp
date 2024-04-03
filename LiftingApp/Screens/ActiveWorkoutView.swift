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
    @EnvironmentObject var activeWorkoutInfo: ActiveWorkoutViewData
    
    @Environment(\.dismiss) private var dismissAction: DismissAction
    
    @ObservedObject private var workoutDisplay: ActiveWorkoutDisplay
    @State private var timerString = "00:00:00"
    private var workoutName: String
    private var workoutID: UUID
    
    @State private var startTime: Date
    @State private var elapsedTime = TimeInterval(0)
    @State private var timer: Timer?
    
    @State private var isShowingFinishConf: Bool = false
    
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
        self.startTime = Date()
        self.workoutID = workout.id
        
        for eSet in workout.exercises {
            let newESD = ActiveExerciseSetDisplay(exercise: eSet.exerciseInfo, intensityForm: eSet.intensityForm, inLBs: true)
            for set in eSet.sets {
                newESD.sets.append(ActiveSetDisplay(targetReps: set.reps, intensity: set.intensity))
            }
            self.workoutDisplay.exercises.append(newESD)
        }
    }
    
    init(workoutDisplay: ActiveWorkoutDisplay, startTime: Date, workoutName: String, workoutID: UUID) {
        self.workoutDisplay = workoutDisplay
        self.startTime = startTime
        self.workoutName = workoutName
        self.workoutID = workoutID
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
                TextField("Notes for next time", text: $workoutDisplay.notes, axis: .vertical)
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
                if !self.allExercisesComplete(displayInfo: workoutDisplay) {
                    isShowingFinishConf = true
                } else {
                    self.closeActiveWorkoutInfo()
                    self.saveToRecord(displayInfo: workoutDisplay)
                    self.dismissAction.callAsFunction()
                }
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
            .alert(isPresented: $isShowingFinishConf) {
                Alert(
                    title: Text("Finish Workout"),
                    message: Text("Not all exercises were entered, finish anyways?"),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Finish")) {
                        self.saveToRecord(displayInfo: workoutDisplay)
                        self.closeActiveWorkoutInfo()
                        self.dismissAction.callAsFunction()
                    }
                )
            }
            //  }
            
            
            // }
        }
        .onAppear {
            if activeWorkoutInfo.startTime == nil {
                startTime = Date()
            }
            activeWorkoutInfo.displayInfo = self.workoutDisplay
            activeWorkoutInfo.startTime = self.startTime
            activeWorkoutInfo.workoutName = self.workoutName
            activeWorkoutInfo.workoutID = self.workoutID
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
    
    func fillDetails() {
        
    }
    
    func everyExerciseComplete() -> Bool {
        for workoutSet in workoutDisplay.exercises {
            for set in workoutSet.sets {
                if !set.completed {
                    return false
                }
            }
        }
        return true
    }
    
    func closeActiveWorkoutInfo() {
        self.activeWorkoutInfo.displayInfo = nil
        self.activeWorkoutInfo.startTime = nil
        self.activeWorkoutInfo.workoutName = nil
        self.activeWorkoutInfo.workoutID = nil
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
        let out = ActiveWorkoutDisplay(workoutID: workout.id)
        for eSet in workout.exercises {
            let newESD = ActiveExerciseSetDisplay(exercise: eSet.exerciseInfo, intensityForm: eSet.intensityForm, inLBs: true)
            newESD.sets = getDisplaySet(eset: eSet)
            out.exercises.append(newESD)
        }
        return out
    }
    
    func saveToRecord(displayInfo: ActiveWorkoutDisplay) {
        let workoutRecord = WorkoutRecord(workoutID: workoutID, notes: displayInfo.notes)
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
    @Published var notes: String = ""
    
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
