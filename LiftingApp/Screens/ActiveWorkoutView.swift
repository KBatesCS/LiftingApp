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
    @State private var timer: AnyCancellable?
    
    @State private var isShowingFinishConf: Bool = false
    
    var elapsedTimeString: String {
        let currentTimeInterval = elapsedTime
        let hours = Int(currentTimeInterval / 3600)
        let minutes = Int((currentTimeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(currentTimeInterval.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    @State private var endRestTime: Date?
    @State private var remainingRestTime = TimeInterval(0)
    var remainingRestString: String {
        let currentTimeInterval = remainingRestTime
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
                                    self.endRestTime = Calendar.current.date(byAdding: .second, value: 90, to: Date())!
                                    self.remainingRestTime = 90
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
            VStack {
                HStack {
                    Spacer()
                    Text("\(elapsedTimeString)")
                        .frame(alignment: .bottom)
                        .font(.title2)
                        .foregroundColor(Color("Text"))
                        .bold()
                        .frame(width: UIScreen.main.bounds.width/3.4, height: 42)
                        .background(Color("Accent"))
                        .cornerRadius(7)
                        .padding(.bottom, 6)
                    
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
                        Text("End Workout")
                            .frame(alignment: .bottom)
                            .font(.title2)
                            .foregroundColor(Color("Text"))
                            .bold()
                            .frame(width: UIScreen.main.bounds.width/1.8, height: 42)
                            .background(Color("Accent"))
                            .cornerRadius(7)
                            .padding(.bottom, 6)
                    })
                    .alert("Finish Workout", isPresented: $isShowingFinishConf, actions: {
                        Button("Finish Anyways", action: {
                            self.saveToRecord(displayInfo: workoutDisplay)
                            self.closeActiveWorkoutInfo()
                            self.dismissAction.callAsFunction()
                        })
                        Button("End Without Saving", role: .destructive, action: {
                            self.closeActiveWorkoutInfo()
                            self.dismissAction.callAsFunction()
                        })
                        Button("Cancel", role: .cancel, action: {})
                    }, message: {Text("Not all exercises have been completed")})
                    Spacer()
                }
                
                if let endRestTime = self.endRestTime {
                    ZStack {
                        Color(.accent)
                            .frame(height: 50)
                        
                        HStack {
                            Button(action: {
                                self.endRestTime = nil
                            }, label: {
                                Text("End")
                                    .bold()
                                    .font(.system(size: 25)) // Adjust size as needed
                                    .padding(10) // Add padding around the button content
                                    .foregroundColor(Color(.text))
                            })
                            
                            Spacer()
                            
                            Text("\(self.remainingRestString)")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 25))
                            Spacer()
                            Button(action: {
                                self.endRestTime =  endRestTime.addingTimeInterval(-10)
                                self.remainingRestTime -= 10
                            }) {
                                Image(systemName: "minus.square.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25) // Adjust size as needed
                                    .padding(10) // Add padding around the button content
                                    .foregroundColor(Color(.text))
                            }
                            Spacer()
                            Button(action: {
                                self.endRestTime = endRestTime.addingTimeInterval(10)
                                self.remainingRestTime += 10
                            }, label: {
                                Image(systemName: "plus.app.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25) // Adjust size as needed
                                    .padding(5) // Add padding around the button content
                                    .foregroundStyle(Color(.text))
                            })
                            Spacer()
                        }
                    }
//                    .transition(.move(edge: .bottom))
//                    .animation(.default)
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .navigationTitle("\(workoutDisplay.workoutName)")
        .onAppear {
            if self.activeWorkoutInfo.display == nil {
                if let oldRecord = getLatestRecord() {
                    workoutDisplay.previousNotes = oldRecord.notes
                    loadPastRecord(pastRecord: oldRecord)
                }
                workoutDisplay.startTime = Date()
                self.activeWorkoutInfo.display = workoutDisplay
            }
            self.elapsedTime = Date().timeIntervalSince(workoutDisplay.startTime)
            
            self.timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    let elapsedTime = Date().timeIntervalSince(workoutDisplay.startTime)
                    if elapsedTime >= 864999 {
                        self.timer?.cancel()
                    } else {
                        self.elapsedTime = elapsedTime
                    }
                    
                    if let restEndTime = endRestTime {
                        let remainingRestTime = restEndTime.timeIntervalSinceNow
                        if remainingRestTime.isLess(than: 0) {
                            self.endRestTime = nil
                        } else {
                            self.remainingRestTime = remainingRestTime
                        }
                    }
                    
                }
        }
        .onDisappear {
            self.timer?.cancel()
        }
    }
    
    func loadPastRecord(pastRecord: CDWorkoutRecord) {
        var pastMap = [UUID: [CDExerciseRecord]]()
        for exercise in pastRecord.exercises {
            let id = exercise.exercise.id
            if pastMap[id] == nil {
                pastMap[id] = [exercise]
            } else {
                pastMap[id]?.append(exercise)
            }
        }
        
        var counterMap = [UUID: [ActiveExerciseSetDisplay]]()
        for exercise in workoutDisplay.exercises {
            let count: Int
            let id = exercise.exercise.id
            if counterMap[id] == nil {
                count = 0
                counterMap[id] = [exercise]
            } else {
                count = counterMap[id]?.count ?? 0
                counterMap[id]?.append(exercise)
            }
            
            let records = pastMap[id]
            let index = min((records?.count ?? 0) - 1, count)
            //if there is a past record, get closest matching (I think)
            if index >= 0 {
                //fill sets
                let record = pastMap[id]![index]
                for (i, set) in exercise.sets.enumerated() {
                    if i < record.sets.count {
                        if record.sets[i].reps != 0 {
                            set.achievedReps = Double(record.sets[i].reps)
                        }
                        if record.sets[i].weight != 0 {
                            set.weight = record.sets[i].weight
                        }
                    }
                }
            }
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

