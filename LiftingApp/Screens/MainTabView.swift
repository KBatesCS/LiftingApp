//
//  MainTabView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/25/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var defaultTab = 2
    @StateObject private var routineList: RoutineList
    //@State public var routineList: [Routine] = []
    
    init() {
        if let loadedRL: RoutineList = load(key: "ExampleUser") {
            _routineList = StateObject(wrappedValue: loadedRL)
        } else {
            _routineList = StateObject(wrappedValue: RoutineList(user: "ExampleUser"))
            routineList.save()
        }
    }
    
    var body: some View {
        TabView (selection: $defaultTab){
            // screen 1
            MainTemp()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }.tag(1)
             
            // Screen 2
            StartWorkoutView()
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
        .environmentObject(routineList)
    }
}

#Preview {
    MainTabView()
}
