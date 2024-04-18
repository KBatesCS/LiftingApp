//
//  MainTabView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/25/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 3
    @StateObject private var routineList: RoutineList
    @StateObject private var recordList: RecordList
    @StateObject private var activeWorkoutInfo: ActiveWorkoutViewData
    //@State public var routineList: [Routine] = []
    
    init() {
        if let loadedRL: RoutineList = load(key: "ExampleUser") {
            _routineList = StateObject(wrappedValue: loadedRL)
        } else {
            _routineList = StateObject(wrappedValue: RoutineList(user: "ExampleUser"))
        }
        
        if let loadedRecL: RecordList = load(key: "ExampleUser/RecordList") {
            _recordList = StateObject(wrappedValue: loadedRecL)
        } else {
            _recordList = StateObject(wrappedValue: RecordList(userID: "ExampleUgfjjser"))
        }
        _activeWorkoutInfo = StateObject(wrappedValue: ActiveWorkoutViewData())
    }
    
    var body: some View {
        TabView (selection: $selectedTab){
            // screen 1
            MainTemp()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }.tag(1)
             
            VideoAnalysisView()
                .tabItem {
                    selectedTab == 2 ?
                    Image(systemName: "camera.fill") :
                    Image(systemName: "camera")
                }.tag(2)
            
            StartWorkoutView()
                .tabItem {
                    selectedTab == 3 ?
                    Image(systemName: "dumbbell.fill") :
                    Image(systemName: "dumbbell")
                }.tag(3)
                        
            //AnalyticsView()
            AnalyticsView()
                .tabItem {
                    selectedTab == 4 ?
                    Image(systemName: "chart.xyaxis.line") :
                    Image(systemName: "chart.xyaxis.line")
                }.tag(4)
            
            
            SettingsView()
                .tabItem {
                    selectedTab == 5 ?
                    Image(systemName: "gearshape") :
                    Image(systemName: "gearshape")
                }.tag(5)
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            let itemAppearance = UITabBarItemAppearance()
            // edit tab appearances here
        }
        .environmentObject(routineList)
        .environmentObject(recordList)
        .environmentObject(activeWorkoutInfo)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

#Preview {
    MainTabView()
}
