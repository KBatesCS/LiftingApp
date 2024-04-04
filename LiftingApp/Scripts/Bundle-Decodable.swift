//
//  Bundle-Decodable.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/21/24.
//

import Foundation

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
