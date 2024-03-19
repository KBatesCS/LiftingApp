//
//  RegisterAccountView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/28/24.
//

import SwiftUI

struct RegisterAccountView: View {
    @State private var username: String = ""
    @State private var password1: String = ""
    @State private var password2: String = ""
    var body: some View {
        VStack {
            Spacer()
            Text("Register Account")
            TextField("Enter Username", text: $username)
                .textFieldStyle(RoundedTextFieldStyle())
            TextField("Enter Password", text: $username)
                .textFieldStyle(RoundedTextFieldStyle())
            TextField("Re-Enter Password", text: $username)
                .textFieldStyle(RoundedTextFieldStyle())
            Button (action: {
                createAccount()
            }, label: {
                Text("Create Account")
            })
            Spacer()
        }
    }
    
    func passwordsEqual() -> Bool{
        return password1 == password2
    }
    
    func createAccount() {
        if passwordsEqual() {
            //create account logic
        }
    }
}

#Preview {
    RegisterAccountView()
}
