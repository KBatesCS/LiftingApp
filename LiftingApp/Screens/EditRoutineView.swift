//
//  EditRoutineView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/20/24.
//

import SwiftUI

struct EditRoutineView: View {
//    @EnvironmentObject var routineList: RoutineList
//    @ObservedObject var routine: Routine
    @State var refresh: Bool = true
    
    @State private var isShowingDeleteConfirmation = false
    @State private var deletionIndexSet: IndexSet?

    @Environment(\.managedObjectContext) var context
    @ObservedObject var routine: CDWorkoutRoutine
    
    init (routine: CDWorkoutRoutine) {
        self.routine = routine
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("RoutineName", text: $routine.name)
                    .frame(alignment: .topLeading)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("Accent"))
                    .textFieldStyle(RoundedTextFieldStyle())
                    .padding()
                
                List {
                    ForEach(routine.workouts, id: \.self) { workout in
                        NavigationLink(destination: EditWorkoutView(workout: workout)) {
                            Text(workout.name)
                        }
                        .foregroundColor(Color("Text"))
                        //.listRowBackground(Color("Accent"))
                         
                    }
                    .onDelete { indexSet in
                        deletionIndexSet = indexSet
                        isShowingDeleteConfirmation = true
                    }
                }
                .listStyle(.inset)
                .alert(isPresented: $isShowingDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Workout"),
                        message: Text("Are you sure you want to delete this workout?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let indexSet = deletionIndexSet {
                                routine.workouts.remove(atOffsets: indexSet)
                            }
                            // Reset deletion state
                            deletionIndexSet = nil
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                Button (action: {
                    let newOrderLoc = routine.workouts.count + 1
                    routine.workouts.append(CDWorkout(name: "Day \(newOrderLoc)", orderLoc: newOrderLoc, context: context))
                    
                }, label: {
                    Text("+ workout")
                        .font(.title2)
                        .foregroundColor(Color(.text))
                        .bold()
                })
                .frame(alignment: .topLeading)
                .padding()
                
                
            }
            
            Spacer()
        }
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

struct erPreviewView: View {
    @FetchRequest(fetchRequest: CDWorkoutRoutine.fetch())
    var workouts: FetchedResults<CDWorkoutRoutine>
    
    @State var workout: CDWorkoutRoutine?
    
    init() {
        let request = CDWorkoutRoutine.fetch()
        _workouts = FetchRequest(fetchRequest: request)
    }
    var body: some View {
        VStack {
            if workout != nil {
                EditRoutineView(routine: workout!)
            }
        } .onAppear {
            workout = workouts[0]
        }
    }
}

struct EditRoutinePreview: PreviewProvider {
    static var previews: some View {
        return erPreviewView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
