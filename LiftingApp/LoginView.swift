//
//  ContentView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/8/24.
//

import SwiftUI

struct LoginView: View {
    @State private var yVal: CGFloat = 0.0
    @State private var opacity: Double = 0.0
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        ZStack {
            Color("Background").edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .offset(x: 0, y: yVal)
                    .padding()
                    .onAppear{
                        withAnimation (.easeInOut(duration: 1.0)) {
                            yVal = -UIScreen.main.bounds.height/5.5
                            
                        }
                    }
                VStack {
                    TextField("", text: $username)
                        .padding(.horizontal, 10)
                        .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
                        .overlay(RoundedRectangle(cornerSize: CGSize(width: 25, height: 25)).stroke(Constants.color1, lineWidth: 1))
                        .ignoresSafeArea(.keyboard)
                    TextField("", text: $password)
                        .padding(.horizontal, 10)
                        .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
                        .overlay(RoundedRectangle(cornerSize: CGSize(width: 25, height: 25)).stroke(Constants.color1, lineWidth: 1))
                        .ignoresSafeArea(.keyboard)
                    
                    Button (action: {
                        isLoggedIn = true
                        
                        //MainTemp()
                    }, label: {
                        Text("Login")
                            .font(.title2)
                            .foregroundColor(Color("Background"))
                            .bold()
                    })
                    .background(
                        NavigationLink(destination: MainTemp(), isActive: $isLoggedIn, label: {EmptyView()})
                    )
                    .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
                    .background(Color("MainColor"))
                    .cornerRadius(21)
                    
                    
                    
                }
                .opacity(opacity)
                .offset(x: 0, y: yVal)
                .padding()
                .onAppear{
                    withAnimation (.easeInOut(duration: 1.0).delay(1.1)) {
                        opacity = 1.0
                    }
                }
                Spacer()
            }
        }
    }
    func login() -> Bool {
        if !username.isEmpty && !password.isEmpty {
            return true
        }
        return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
