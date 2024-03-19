//
//  ActiveWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/15/24.
//

import SwiftUI

struct ActiveWorkoutView: View {
    @EnvironmentObject var routineList: RoutineList
    @ObservedObject var workout: Workout
    @State private var startTime = Date()
    @State private var timerString = "00:00:00"
    @State private var isTimerRunning = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var temp: Double?
    @FocusState var numPadFocus: Bool
    
    var body: some View {
        ZStack {
            Color("Background")
            
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
                
                // LIST OF EVERY EXERCISE
                List {
                    ForEach(workout.exercises) { exerciseSet in
                        Section {
                            var displaySet = getDisplaySet(eset: exerciseSet)
                            Table(displaySet) {
                                TableColumn("target reps") { set in
                                    Text("\(set.targetReps)")
                                }
                                TableColumn("intensity") { set in
                                    Text("\(set.intensity)")
                                }
                                TableColumn("reps") { set in
                                    Text("\(set.achievedReps)")
                                }
                                TableColumn("weight") { set in
                                    Text("\(set.weight)")
                                }
                            }
                            .scaledToFit()
                        } header: {
                            Text(exerciseSet.exerciseInfo.name)
                                .scaleEffect(1.3)
                                .bold()
                            // IF ALL EXERCISES ARE SAME INTENSITY, NO NEED FOR A NEW COLUMN
                            if (exerciseSet.intensityForm != IntensityType.None
                            && allSameIntensity(exerciseSet: exerciseSet)) {
                                if (exerciseSet.intensityForm == IntensityType.RPE) {
                                    Text("@ RPE \(exerciseSet.sets[0].intensity)")
                                } else {
                                    Text("@ \(exerciseSet.sets[0].intensity)% 1RPM")
                                }
                            }
                        }
                    }
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
    }
    
    func stopTimer() {
        self.timer.upstream.connect().cancel()
        self.isTimerRunning = false
    }
    
    func startTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        self.isTimerRunning = true
    }
    
    func allSameIntensity(exerciseSet: ExerciseSet) -> Bool{
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
    
    func getDisplaySet(eset: ExerciseSet) -> [SetDisplay]{
        var out: [SetDisplay] = []
        
        for set in eset.sets {
            out.append(SetDisplay(targetReps: set.reps, intensity: set.intensity))
        }
        
        return out
    }
}

class SetDisplay: Identifiable {
    let targetReps: Int
    let intensity: Int
    var achievedReps: Int
    var weight: Int
    
    init(targetReps: Int, intensity: Int, achievedReps: Int = 0, weight: Int = 0) {
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
