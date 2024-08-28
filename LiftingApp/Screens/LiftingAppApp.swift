//
//  LiftingAppApp.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/8/24.
//

import SwiftUI

@main
struct LiftingAppApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .onChange(of: scenePhase) { _ in
                    PersistenceController.shared.save()
                }
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .preferredColorScheme(.dark)
        }
    }
}

struct Constants {
    static let color1 = Color(red: 0/255, green:  221/255, blue: 22/255, opacity: 1.0)
}
