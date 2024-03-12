//
//  CustomFunctions.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/12/24.
//

import Foundation

func load<T: Codable>(key: String) -> T? {
    var out: T
    if let data = UserDefaults.standard.data(forKey: key) {
        if let decoded = try? JSONDecoder().decode(T.self, from: data) {
            out = decoded
            return out
        }
    }
    return nil
}

func save<T: Codable>(key: String, data: T) {
    
}
