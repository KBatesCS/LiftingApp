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
                .overlay(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).stroke(Color("Accent"), lineWidth: 2))
                .foregroundStyle(Color(.text))
    }
}

struct testView: View {
    @State var tempString: String
    var body: some View {
        TextField("test", text: $tempString)
            .textFieldStyle(RoundedTextFieldStyle())
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .resizable()
                    .frame(width: 20, height: 20)
                configuration.label
            }
        }
    }
}

struct StatisticBox: View {
    let title: String
    let content: String

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 5)
            Text(content)
                .font(.title)
                .foregroundColor(.white)
                .padding(.bottom, 5)

        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.accent))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.accent).opacity(0.5), lineWidth: 5)
                .blendMode(.multiply)
        )
    }
}


#Preview {
    testView(tempString: "hello")
}
