//
//  ActiveWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/15/24.
//

import SwiftUI
import Combine
import CoreData

struct ActiveWorkoutView: View {
    @FetchRequest(fetchRequest: CDWorkoutRecord.fetch())
    var previousWorkoutRecordsList: FetchedResults<CDWorkoutRecord>
    
    @State var previousWorkoutRecord: CDWorkoutRecord? = nil
    
    @Environment(\.managedObjectContext) var context
    
    @EnvironmentObject var activeWorkoutInfo: ActiveWorkoutDisplayContainer
    @ObservedObject private var workoutDisplay: ActiveWorkoutDisplay
    
    @Environment(\.dismiss) private var dismissAction: DismissAction
    
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
    
    init(workout: CDWorkout) {
        self.workoutDisplay = ActiveWorkoutDisplay(startTime: Date(), workoutName: workout.name, workoutID: workout.uuid)
        
        for eSet in workout.exercises {
            let newESD = ActiveExerciseSetDisplay(exercise: eSet.exercise, intensityForm: eSet.intensityType, inLBs: true)
            for set in eSet.sets {
                newESD.sets.append(ActiveSetDisplay(targetReps: set.targetReps, intensity: set.intensity))
            }
            self.workoutDisplay.exercises.append(newESD)
        }
    }
    
    init(workoutDisplay: ActiveWorkoutDisplay) {
        self.workoutDisplay = workoutDisplay
    }
    
    
    var body: some View {
        HStack {
            Spacer()
            Text(workoutDisplay.workoutName)
                .scaledToFill()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Spacer()
            
            Text("\(elapsedTimeString)")
            
            Spacer()
            
        }
        
        Spacer()
        
        
        
        List {
            
            if !workoutDisplay.previousNotes.isEmpty {
                Section {
                    Text(workoutDisplay.previousNotes)
                } header: {
                    Text("Previous Notes")
                }
            }
            
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
                                    if self.workoutDisplay.exercises[woIndex].sets[sindex].completed {
                                        Image(systemName: self.workoutDisplay.exercises[woIndex].sets[sindex].completed ? "checkmark" : "")
                                    }
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
        }
        .onAppear {
            if self.activeWorkoutInfo.display == nil {
                if let oldRecord = getLatestRecord() {
                    workoutDisplay.previousNotes = oldRecord.notes
                }
                workoutDisplay.startTime = Date()
                self.activeWorkoutInfo.display = workoutDisplay
            }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.elapsedTime = Date().timeIntervalSince(workoutDisplay.startTime)
                if (self.elapsedTime >= 864999) { // should stop the timer right before 10 days hits.
                    self.timer?.invalidate()
                }
            }
        }
        .onDisappear {
            self.timer?.invalidate()
        }
    }
    
    func getLatestRecord() -> CDWorkoutRecord? {
        let request = CDWorkoutRecord.fetch()
        request.predicate = NSPredicate(format: "workoutUUID_ == %@", workoutDisplay.workoutID.uuidString)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "date_", ascending: false)]
        do {
            let oldRecords = try context.fetch(request)
            if !oldRecords.isEmpty {
                print(previousWorkoutRecord?.workoutUUID ?? "no workoutuuid on previous record????")
                print(workoutDisplay.workoutID.uuidString)
                previousWorkoutRecord = oldRecords[0]
                return previousWorkoutRecord
            }
        } catch {
            print(error)
            return nil
        }
        print("no previous records found")
        return nil
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
        self.activeWorkoutInfo.display = nil
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
    
    func getDisplaySet(eset: CDExerciseSet) -> [ActiveSetDisplay] {
        var out: [ActiveSetDisplay] = []
        
        for set in eset.sets {
            out.append(ActiveSetDisplay(targetReps: set.targetReps, intensity: set.intensity))
        }
        
        return out
    }
    
    func saveToRecord(displayInfo: ActiveWorkoutDisplay) {
        
        let workoutRecord = CDWorkoutRecord(notes: displayInfo.notes, usrStr: "ExampleUser", workoutUUID: workoutDisplay.workoutID, context: context)
        
        for exerciseIndex in workoutDisplay.exercises.indices {
            let esetDisplay = workoutDisplay.exercises[exerciseIndex]
            let esetRecord: CDExerciseRecord = CDExerciseRecord(inLBs: esetDisplay.inLBs, exercise: esetDisplay.exercise, orderLoc: Int32(exerciseIndex), context: context)
            for setIndex in esetDisplay.sets.indices {
                let setDisplay = esetDisplay.sets[setIndex]
                let achievedReps: Int = Int((setDisplay.achievedReps != nil) ? setDisplay.achievedReps! : 0)
                let weight: Double = (setDisplay.weight != nil) ? setDisplay.weight! : 0.0
                let setRecord: CDSetRecord = CDSetRecord(reps: Int32(achievedReps), weight: weight, completed: setDisplay.completed, orderLoc: Int32(setIndex), context: context)
                esetRecord.sets.append(setRecord)
            }
            workoutRecord.exercises.append(esetRecord)
        }
        
        
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



struct awPreviewView: View {
    @FetchRequest(fetchRequest: CDWorkout.fetch())
    var workouts: FetchedResults<CDWorkout>
    
    @State var workout: CDWorkout?
    
    init() {
        let request = CDWorkout.fetch()
        _workouts = FetchRequest(fetchRequest: request)
    }
    var body: some View {
        VStack {
            if workout != nil {
                ActiveWorkoutView(workout: workout!)
            }
        } .onAppear {
            workout = workouts[0]
        }
    }
}

struct ActiveWorkoutPreview: PreviewProvider {
    static var previews: some View {
        return awPreviewView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

