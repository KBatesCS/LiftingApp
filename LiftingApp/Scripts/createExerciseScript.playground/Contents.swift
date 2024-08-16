import UIKit
import Foundation
import SwiftUI

let eArr = [
    //Chest Focused Exercises
    Exercise(name: "", desc: "", primaryMusclesWorked: [], secondaryMusclesWorked: [])
]

// Encode the array to JSON data
let jsonEncoder = JSONEncoder()
jsonEncoder.outputFormatting = .prettyPrinted

do {
    let jsonData = try jsonEncoder.encode(eArr)
          
          // Define the directory where you want to save the file
    let directoryURL = URL(fileURLWithPath: "/Users/kevinbates/Documents/GitHub Repositories/LiftingApp/LiftingApp/LoadableData")
          
    //let fileURL = directoryURL.appendingPathComponent("defaultData.json")
           
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        // Define the destination file URL in the documents directory
    let fileURL = documentsDirectory!.appendingPathComponent("defaultData.json")
           // Delete existing file if it exists
    if FileManager.default.fileExists(atPath: fileURL.path) {
        try FileManager.default.removeItem(at: fileURL)
        print("Existing file deleted.")
}
           
           // Save JSON data to file
    try jsonData.write(to: fileURL)
           
    print("Default JSON file created at: \(fileURL.path)")
} catch {
    print("Error: \(error.localizedDescription)")
}

func deleteFileIfExists(at url: URL) {
    do {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
            print("Existing file deleted.")
        }
    } catch {
        print("Error deleting file: \(error.localizedDescription)")
    }
}
