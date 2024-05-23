//
//  MainTemp.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/8/24.
//

import SwiftUI

struct SelectRoutineView: View {
    //@EnvironmentObject private var routineList: RoutineList
    @Environment(\.managedObjectContext) var context
    @State private var isShowingDeleteConfirmation = false
    @State private var deletionIndexSet: IndexSet?
    
    @FetchRequest(fetchRequest: CDWorkoutRoutine.fetch())
    var workoutRoutines: FetchedResults<CDWorkoutRoutine>
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                List {
                    ForEach(workoutRoutines) { routine in
                        NavigationLink(destination: EditRoutineView(routine: routine)) {
                            VStack {
                                Text(routine.name)                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 23))
                                
                                Text("\(routine.workouts.count) workouts")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(Color(.text).opacity(0.8))
                            }
                        
                        }
                        //.foregroundColor(Color("Text"))
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
                        title: Text("Delete Routine"),
                        message: Text("Are you sure you want to delete this workout?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let indexSet = deletionIndexSet {
                                indexSet.forEach { index in
                                    CDWorkoutRoutine.delete(workoutRoutine: workoutRoutines[index])
                                }
                            }
                            
                            for index in workoutRoutines.indices {
                                workoutRoutines[index].orderLoc = index + 1
                            }
                            
                            // Reset deletion state
                            deletionIndexSet = nil
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                Spacer()
                Button (action: {
                    let num = workoutRoutines.filter({$0.userStr == "ExampleUser"}).count + 1
                    _ = CDWorkoutRoutine(name: "Routine \(num)", userStr: "ExampleUser", orderLoc: num, context: context)
                }, label: {
                    Text("+ routine")
                        .font(.title2)
                        .foregroundColor(Color(.text))
                        .bold()
                        .padding(.vertical, 15)
                        .padding(.horizontal, 40)
                })
                .background(Color(.accent).opacity(0.2))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color(.accent), lineWidth: 3))
                //.frame(alignment: .topLeading)
                .padding()
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .navigationTitle("Routines")
              .bold()
        }
        .onAppear {
            //PersistenceController.shared.save()
        }
        .ignoresSafeArea(.all)
    }
}

struct MainTemp_Previews: PreviewProvider {
    static var previews: some View {
        SelectRoutineView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
