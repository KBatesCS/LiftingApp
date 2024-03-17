//
//  SwiftUIView.swift
//  LiftingApp
//
//  Created by Evan Banks on 3/16/24.
//

import SwiftUI

struct SettingsView: View {
    
    /* @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("systemThemEnabled") private var systemThemeEnabled = false */
    
    var body: some View {
        NavigationView{
            Form{
                
                Section(header: Text("Display Options"),
                footer: Text("System settings will override Dark Mode setting and use the current device theme")){
                    
                    Toggle(isOn: .constant(true),
                           label:{
                        Text("Dark Mode")
                    })
                    Toggle(isOn:
                            .constant(true),
                           label:{
                        Text("System Settings")
                    })
                        Toggle(isOn:
                                .constant(true),
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
            
        }
    }
}
enum Links{
    static let email = "mailto:email"
}
#Preview {
    SettingsView()
}
