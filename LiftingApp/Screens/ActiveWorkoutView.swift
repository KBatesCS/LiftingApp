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
    
    
    var body: some View {
        ZStack {
            Color("Background")
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
                                let currentTimeInterval = Date().timeIntervalSince(self.startTime)
                                let hours = Int(currentTimeInterval / 3600)
                                let minutes = Int((currentTimeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
                                let seconds = Int(currentTimeInterval.truncatingRemainder(dividingBy: 60))

                                self.timerString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
                
                ForEach(workout.exercises) { exerciseSet in
                    Text(exerciseSet.exerciseInfo.name)
                }
                Spacer()
                Button (action: {
                    stopTimer()
                }, label: {
                    Text("Finish Workout")
                        .frame(alignment: .bottom)
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
}

/*
#Preview {
    ActiveWorkoutView()
}
*/
