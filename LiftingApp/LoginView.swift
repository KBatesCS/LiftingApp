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
                        login(completion: {success in
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
    func login(completion: @escaping (Bool) -> ()) {
        if !username.isEmpty && !password.isEmpty {
            let SERVER_URL = "http://127.0.0.1:3000/auth/local/login";
            let parameters: [String: String] = [
                "email": username,
                "password": password
            ]
            AF.request(SERVER_URL, method: .post, parameters: parameters).responseData { response in
                if response.response?.statusCode == 200 {
                    switch response.result {
                        case .success(let data):
                            do {
                                let asJSON = (try JSONSerialization.jsonObject(with: data)) as? [String: Any]
                                print(asJSON!["access_token"])
//                                let keychain = Keychain(server: "http://127.0.0.1", protocolType: .http)
//                                keychain["server_access_token"] = asJSON!["access_token"] as? String
                                completion(true)
                            } catch {
                                print(error)
                            }
                        case .failure(let error):
                            print(error)
                        }
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
