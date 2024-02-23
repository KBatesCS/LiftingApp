//
//  EditRoutineView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/20/24.
//

import SwiftUI

struct EditRoutineView: View {
    var curRoutine: Routine
    private var isNew: Bool
    
    @State private var name: String = ""
    
    init(curRoutine: Routine? = nil) {
        self.curRoutine = curRoutine ?? Routine()
        self.isNew = (curRoutine == nil)
        self.name = curRoutine?.name ?? "error"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("RoutineName", text: $name)
                    .frame(alignment: .topLeading)
                    .multilineTextAlignment(.center)
                Spacer()
                ForEach(0..<curRoutine.workouts.count, id: \.self) {
                    WorkoutMetaDislay(workout: curRoutine.workouts[$0])
                }
                Button (action: {
                    
                }, label: {
                    Text("+ workout")
                        .font(.title2)
                        .foregroundColor(Color("Background"))
                        .bold()
                })
                
            }
            
            Spacer()
        }
    }
    
    func save() {
        
    }
}

struct WorkoutMetaDislay: View {
    
    let workout: Workout
    
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
            Text(workout.name)
        }
        .padding()
    }
    
    
}

#Preview {
    EditRoutineView()
}
