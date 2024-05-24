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
                Text("Routines")
                    .font(.system(size: 40))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
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
                        .accentedButtonTextStyle()
                })
                .accentedButtonStyle()
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
              .bold()
        }
        .onAppear {
            //PersistenceController.shared.save()
        }
        .ignoresSafeArea(.all)
        .navigationBarHidden(true)
    }
}

struct MainTemp_Previews: PreviewProvider {
    static var previews: some View {
        SelectRoutineView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
