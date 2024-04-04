//
//  ContentView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/8/24.
//

import SwiftUI
import Alamofire
import KeychainAccess

struct LoginView: View {
    @State var isLoggedIn: Bool = false
    var body: some View {
        if (isLoggedIn) {
            MainTabView()
        }
        else {
            LoginViewScreen(isLoggedIn: $isLoggedIn)
        }
    }
}

struct LoginViewScreen: View {
    @State private var yVal: CGFloat = 0.0
    @State private var opacity: Double = 0.0
    @State private var username: String = ""
    @State private var password: String = ""
    
    @Binding var isLoggedIn: Bool
    
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
                        .overlay(RoundedRectangle(cornerSize: CGSize(width: 25, height: 25)).stroke(Color("Accent"), lineWidth: 1))
                        .keyboardType(.emailAddress)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    SecureField("", text: $password)
                        .padding(.horizontal, 10)
                        .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
                        .overlay(RoundedRectangle(cornerSize: CGSize(width: 25, height: 25)).stroke(Color("Accent"), lineWidth: 1))
                    Button (action: {
                        AuthService.authenticateLocal(username: username, password: password, completion: {success in
                                isLoggedIn = success
                        })
                    }, label: {
                        Text("Login")
                            .font(.title2)
                            .foregroundColor(Color("Background"))
                            .bold()
                    })
                    .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
                    .background(Color("Accent"))
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
            .ignoresSafeArea(.keyboard)
        }
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
