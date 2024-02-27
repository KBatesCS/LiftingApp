//
//  MainTemp.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/8/24.
//

import SwiftUI

struct MainTemp: View {
    @State private var routineList: [Routine]
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "ExampleUser") {
            if let decoded = try? JSONDecoder().decode([Routine].self, from: data) {
                routineList = decoded
                return
            }
        }
        routineList = []
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("hello?")
                Spacer()
                List(Array(routineList.enumerated()), id: \.element.id) { index, routine in
                    if let data = UserDefaults.standard.data(forKey: routine.id.uuidString) {
                        if let loadedRoutine = try? JSONDecoder().decode(Routine.self, from: data) {
                            NavigationLink(destination: EditRoutineView(curRoutine: loadedRoutine)) {
                                Text(loadedRoutine.name)
                            }
                        }
                    }
                }
                Spacer()
                Button (action: {
                    routineList.append(Routine())
                    save()
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
