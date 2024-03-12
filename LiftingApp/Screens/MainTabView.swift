//
//  MainTabView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/25/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var defaultTab = 2
    @ObservedObject private var routineList: RoutineList
    //@State public var routineList: [Routine] = []
    
    init() {
        if let loadedRL: RoutineList = load(key: "ExampleUser") {
            routineList = loadedRL
        } else {
            routineList = RoutineList(user: "ExampleUser")
            routineList.save()
        }
    }
    
    var body: some View {
        TabView (selection: $defaultTab){
            // screen 1
            MainTemp(routineList: self.routineList)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }.tag(1)
             
            // Screen 2
            StartWorkoutView(routineList: self.routineList)
                .tabItem {
                    Image(systemName: "dumbbell")
                }.tag(2)
                        
            // Screen 3
            //replace with whatever you need for now.
            EmptyView()
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
