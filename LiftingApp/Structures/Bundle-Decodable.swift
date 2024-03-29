//
//  Bundle-Decodable.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/21/24.
//

import Foundation
import SwiftUI

extension Bundle {
    func decode(_ file: String) -> [Exercise] {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        let decorder = JSONDecoder()
        
        guard let loaded = try? decorder.decode([Exercise].self, from: data) else {
            fatalError("Failed to decode \(file) from bundle")
        }
        
        return loaded
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize){
        
    }
}


extension View {
    func getSize(_ size: Binding<CGSize>) -> some View {
        modifier(GetSizeModifier(size: size))
    }
}

struct GetSizeModifier: ViewModifier {
    @Binding var size: CGSize
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    let proxySize = proxy.size
                    Color.clear
                        .task(id: proxy.size) {
                            $size.wrappedValue = proxySize
                        }
                }
            )
    }
}

