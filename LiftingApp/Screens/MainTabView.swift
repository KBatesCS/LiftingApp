//
//  MainTabView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/25/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var defaultTab = 2
    //@State public var routineList: [Routine] = []
    
    var body: some View {
        TabView (selection: $defaultTab){
            // screen 1
            EditRoutineView(curRoutine: Routine(name: "new routine"))
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }.tag(1)
             
            // Screen 2
            StartWorkoutView()
                .tabItem {
                    Image(systemName: "dumbbell")
                }.tag(2)
                        
            // Screen 3
            MainTemp()
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                }.tag(3)
        }
        .onAppear {
            /*
            let defaults = UserDefaults.standard
            if let savedRoutineList = defaults.object(forKey: "ExampleUser") as? Data {
                let decoder = JSONDecoder()
                if let loadedRoutineList = try? decoder.decode([Routine].self, from: savedRoutineList) {
                    routineList = loadedRoutineList
                }
            }
             */
        }
    }
}

#Preview {
    MainTabView()
}
