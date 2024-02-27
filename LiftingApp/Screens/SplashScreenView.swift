//
//  SplashScreenView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/8/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var yVal: CGFloat = 0.0
    @State private var isActive: Bool = false
    var body: some View {
        ZStack {
            if self.isActive {
                if self.isLoggedIn() {
                    MainTabView()
                } else {
                    LoginView()
                }
            } else {
                Color("Background").edgesIgnoringSafeArea(.all)
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                }
            }
            
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
    
    func isLoggedIn() -> Bool {
        return true
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
