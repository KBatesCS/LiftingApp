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
                //                        .frame(maxWidth: .infinity)
                //                        .frame(alignment: .topLeading)
                    .multilineTextAlignment(.leading)
                
                //                        .foregroundColor(Color("Accent"))
                    .textFieldStyle(RoundedTextFieldStyle())
                    .padding()
                
                    .overlay(Image(systemName: "square.and.pencil").frame(maxWidth: .infinity, alignment: .trailing).padding(.trailing, 22).foregroundStyle(Color(.text)))
                Spacer()
                
                List {
                    ForEach(routine.workouts, id: \.self) { workout in
                        NavigationLink(destination: EditWorkoutView(workout: workout)) {
                            VStack {
                                Text(workout.name)                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 23))
                                
                                Text("\(workout.exercises.count) exercises")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(Color(.text).opacity(0.8))
                            }
                        }
                        .foregroundColor(Color("Text"))
                        //.listRowBackground(Color("Accent"))
                        
                    }
                    .onDelete { indexSet in
                        deletionIndexSet = indexSet
                        isShowingDeleteConfirmation = true
                    }
                    .listRowSeparatorTint(Color(.accent))
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
                        .padding(.vertical, 15)
                        .padding(.horizontal, 40)
                })
                .background(Color(.accent).opacity(0.2))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color(.accent), lineWidth: 3))
                .frame(alignment: .topLeading)
                .padding()
                
                
            }
            
            Spacer()
        }
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
