//
//  StartWorkoutView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 1/25/24.
//

import SwiftUI

struct StartWorkoutView: View {
    var body: some View {
        VStack {
            HStack {
                Text("active workout")
                    .bold()
                    .frame(alignment: .top)
                Image(systemName: "arrowtriangle.down.fill")
                    .scaleEffect(0.7)
                    .underline()
            }
            .underline()
            Spacer()
            ScrollView {
                
            }
            Button (action: {
                
            }, label: {
                Text("Begin")
                    .font(.title2)
                    .foregroundColor(Color("Background"))
                    .bold()
            })
            .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
            .background(Color("Accent"))
            .cornerRadius(21)
            
            Spacer()
        }
    }
}

#Preview {
    StartWorkoutView()
}
