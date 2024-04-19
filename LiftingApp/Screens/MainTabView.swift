//
//  MainTabView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/25/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 3

    @StateObject private var activeWorkoutInfo: ActiveWorkoutViewData
    
    init() {
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
        .onChange(of: selectedTab) { _ in
            PersistenceController.shared.save()
        }
        .environmentObject(activeWorkoutInfo)
        //.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

#Preview {
    MainTabView()
}
