import UIKit
    
let e1 = Exercise(name: "BenchPress", primaryMusclesWorked: [Muscles.chest], secondaryMusclesWorked: [Muscles.shoulder, Muscles.tricep])
let e2 = Exercise(name: "Pullup", primaryMusclesWorked: [Muscles.back], secondaryMusclesWorked: [Muscles.bicep])
let e3 = Exercise(name: "Chest Press", primaryMusclesWorked: [Muscles.chest], secondaryMusclesWorked: [Muscles.frontdeltoid, Muscles.tricep])
let e4 = Exercise(name: "Chest Fly", primaryMusclesWorked: [Muscles.chest], secondaryMusclesWorked: [Muscles.frontdeltoid])
let e5 = Exercise(name: "Dip", primaryMusclesWorked: [Muscles.chest, Muscles.frontdeltoid], secondaryMusclesWorked: [Muscles.tricep])
let e6 = Exercise(name: "Pushup", primaryMusclesWorked: [Muscles.chest, Muscles.frontdeltoid], secondaryMusclesWorked: [Muscles.tricep, Muscles.abdominal])
let e7 = Exercise(name: "Rear Delt Row", primaryMusclesWorked: [Muscles.reardeltoid, Muscles.trapezius], secondaryMusclesWorked: [Muscles.rotatorcuff, Muscles.bicep, Muscles.forearmflexor])
let e8 = Exercise(name: "Shoulder Press", primaryMusclesWorked: [Muscles.frontdeltoid], secondaryMusclesWorked: [Muscles.tricep, Muscles.lateraldeltoid])
let e9 = Exercise(name: "Overhead Press", primaryMusclesWorked: [Muscles.frontdeltoid], secondaryMusclesWorked: [Muscles.tricep, Muscles.lateraldeltoid])
let e10 = Exercise(name: "Reverse Cable Fly", primaryMusclesWorked: [Muscles.reardeltoid, Muscles.rotatorcuff], secondaryMusclesWorked: [Muscles.trapezius])
let e11 = Exercise(name: "Dumbell front Raise", primaryMusclesWorked: [Muscles.frontdeltoid], secondaryMusclesWorked: [Muscles.reardeltoid])
let e12 = Exercise(name: "Seated Row", primaryMusclesWorked: [Muscles.lat, Muscles.trapezius, Muscles.reardeltoid], secondaryMusclesWorked: [Muscles.bicep, Muscles.forearmflexor, Muscles.rotatorcuff])
let e13 = Exercise(name: "Deadlift", primaryMusclesWorked: [Muscles.glute, Muscles.lowback], secondaryMusclesWorked: [Muscles.quad, Muscles.hamstring, Muscles.adductor, Muscles.trapezius, Muscles.forearmflexor])
let e14 = Exercise(name: "Lat Pulldown", primaryMusclesWorked: [Muscles.lat], secondaryMusclesWorked: [Muscles.reardeltoid, Muscles.bicep, Muscles.rotatorcuff])
let e15 = Exercise(name: "Jefferson Curl", primaryMusclesWorked: [Muscles.lowback], secondaryMusclesWorked: [Muscles.adductor, Muscles.glute, Muscles.hamstring])
let e16 = Exercise(name: "Lunge", primaryMusclesWorked: [Muscles.quad, Muscles.glute], secondaryMusclesWorked: [Muscles.adductor])
let e17 = Exercise(name: "Squat", primaryMusclesWorked: [Muscles.quad, Muscles.adductor, Muscles.glute, Muscles.lowback], secondaryMusclesWorked: [Muscles.calf])
let e18 = Exercise(name: "Leg Extension", primaryMusclesWorked: [Muscles.quad])
let e19 = Exercise(name: "Leg Press", primaryMusclesWorked: [Muscles.quad, Muscles.glute, Muscles.adductor], secondaryMusclesWorked: [Muscles.hamstring])
let e20 = Exercise(name: "Leg Curl", primaryMusclesWorked: [Muscles.hamstring])
let e21 = Exercise(name: "Romanian Deadlift", primaryMusclesWorked: [Muscles.glute, Muscles.lowback, Muscles.hamstring  ], secondaryMusclesWorked: [Muscles.adductor, Muscles.trapezius])
let e22 = Exercise(name: "Calf Raise", primaryMusclesWorked: [Muscles.calf])
let e23 = Exercise(name: "Heel Drop", primaryMusclesWorked: [Muscles.calf])
let e24 = Exercise(name: "Heel Raise", primaryMusclesWorked: [Muscles.calf])
let e25 = Exercise(name: "Bicep Curl", primaryMusclesWorked: [Muscles.bicep], secondaryMusclesWorked: [Muscles.forearmflexor])
let e26 = Exercise(name: "Hammer Curl", primaryMusclesWorked: [Muscles.bicep, Muscles.forearmflexor])
let e27 = Exercise(name: "Preacher Curl", primaryMusclesWorked: [Muscles.bicep], secondaryMusclesWorked: [Muscles.forearmflexor])
let e28 = Exercise(name: "Bench Dip", primaryMusclesWorked: [Muscles.tricep], secondaryMusclesWorked: [Muscles.chest])
let e29 = Exercise(name: "Tricep Pushdown", primaryMusclesWorked: [Muscles.tricep])
let e30 = Exercise(name: "Tricep Extension", primaryMusclesWorked: [Muscles.tricep], secondaryMusclesWorked: [Muscles.forearmflexor])
let e31 = Exercise(name: "Plate Pinch", primaryMusclesWorked: [Muscles.forearmflexor])
let e32 = Exercise(name: "Wrist Curl", primaryMusclesWorked: [Muscles.forearmflexor])
let e33 = Exercise(name: "Wrist Extension", primaryMusclesWorked: [Muscles.], secondaryMusclesWorked: [Muscles.forearmextensor])
let e34 = Exercise(name: "Crunch", primaryMusclesWorked: [Muscles.abdominal], secondaryMusclesWorked: [Muscles.oblique])
let e35 = Exercise(name: "Plank", primaryMusclesWorked: [Muscles.abdominal], secondaryMusclesWorked: [Muscles.oblique])
let e36 = Exercise(name: "Leg Raise", primaryMusclesWorked: [Muscles.abdominal], secondaryMusclesWorked: [Muscles.oblique])
let e37 = Exercise(name: "Suitcases", primaryMusclesWorked: [Muscles.abdominal], secondaryMusclesWorked: [Muscles.oblique])
let e38 = Exercise(name: "Windshield Wiper", primaryMusclesWorked: [Muscles.oblique], secondaryMusclesWorked: [Muscles.abdominal])


let eArr = [e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14, e15, e16,
e17, e18, e19, e20, e21, e22, e23, e24, e25, e26, e27, e28, e29, e30, e31, e32, e33,
e34, e35, e36, e37, e38]

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
