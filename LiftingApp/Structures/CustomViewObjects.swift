//
//  CustomViewObjects.swift
//  LiftingApp
//
//  Created by Kevin Bates on 2/22/24.
//

import SwiftUI



struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding(.horizontal, 10)
                .frame(width: UIScreen.main.bounds.width/1.6, height: 42)
                .overlay(RoundedRectangle(cornerSize: CGSize(width: 25, height: 25)).stroke(Color("Accent"), lineWidth: 2))
                .foregroundStyle(.white)
    }
}

struct testView: View {
    @State var tempString: String
    var body: some View {
        TextField("test", text: $tempString)
            .textFieldStyle(RoundedTextFieldStyle())
    }
}

#Preview {
    testView(tempString: "hello")
}
