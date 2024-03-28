//
//  SwiftUIView.swift
//  LiftingApp
//
//  Created by Evan Banks on 3/16/24.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.colorScheme) private var userColorScheme
    
    @State private var viewColorScheme: ColorScheme = .dark
    
    @State private var isOn: Bool = false
    
    var body: some View {
        NavigationView{
            Form{
                
                Section(header: Text("Display Options"),
                        footer: Text("System settings will override Dark Mode setting and use the current device theme")){
                    
                    Toggle(isOn: $isOn,
                           label:{
                        Text("Dark Mode")
                    })
                    /* Toggle(isOn: $systemThemeEnabled,
                     label:{
                     Text("System Settings")
                     }) */
                    Toggle(isOn:
                            .constant(false),
                           label:{
                        Text("Show weight in Kilos")
                    })
                    
                    
                    
                }
                Section{
                    Link("Contact us via email",
                         destination: URL(string: Links.email)!)
                };
                
                
            }
            .navigationTitle("Settings")
            
            Spacer()
        }.preferredColorScheme(viewColorScheme)
         .onAppear(){
         switchAppearance()
         }
         .onChange(of: isOn, perform:{
         newValue in
         if newValue == false{
         viewColorScheme = .light
         return
         }
         viewColorScheme = .dark
         })
         
         }
          func switchAppearance(){
             viewColorScheme = userColorScheme
             if viewColorScheme == .dark{
                 isOn = true
                 return
             }
             isOn = false
         }
    }
    enum Links{
        static let email = "mailto:email"
    }
    struct SettingsView_Previews: PreviewProvider{
        static var previews: some View{
            SettingsView()
        }
    }

