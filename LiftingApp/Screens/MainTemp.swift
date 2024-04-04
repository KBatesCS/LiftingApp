//
//  MainTemp.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/8/24.
//

import SwiftUI

struct MainTemp: View {
    @EnvironmentObject private var routineList: RoutineList
    
    @State private var isShowingDeleteConfirmation = false
    @State private var deletionIndexSet: IndexSet?
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Routines")
                    .bold()
                    .scaledToFit()
                Spacer()
                
                List {
                    ForEach(routineList.routines) { routine in
                        NavigationLink(destination: EditRoutineView(routine: routine)) {
                            
                            Text(routine.name)
                        }
                        .foregroundColor(Color("Text"))
                        .listRowBackground(Color("Accent"))
                    }
                    .onDelete { indexSet in
                        deletionIndexSet = indexSet
                        isShowingDeleteConfirmation = true
                    }
                }
                .listRowSpacing(10)
                
                .alert(isPresented: $isShowingDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Routine"),
                        message: Text("Are you sure you want to delete this workout?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let indexSet = deletionIndexSet {
                                routineList.routines.remove(atOffsets: indexSet)
                                routineList.refreshAndSave()
                            }
                            // Reset deletion state
                            deletionIndexSet = nil
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                /*
                List {
                    ForEach(routineList.routines.indices, id: \.self) { index in
                        NavigationLink(destination: EditRoutineView(routine: $routineList.routines[index])) {
                            Text(routineList.routines[index].name)
                        }
                    }
                }
                 */
                
                Spacer()
                Button (action: {
                    routineList.routines.append(Routine())
                    routineList.refreshAndSave()
                }, label: {
                    Text("+ routine")
                        .font(.title2)
                        .foregroundColor(Color("Background"))
                        .bold()
                })
                .frame(alignment: .topLeading)
                .padding()
                Spacer()
            }
        }
        //.environmentObject(routineList)
    }
    
    
    
    func save() {
        if let encoded = try? JSONEncoder().encode(routineList) {
            UserDefaults.standard.set(encoded, forKey: "ExampleUser")
        }
    }
}

struct MainTemp_Previews: PreviewProvider {
    static var previews: some View {
        MainTemp()
    }
}
