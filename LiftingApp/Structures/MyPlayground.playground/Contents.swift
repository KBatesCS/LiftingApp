import Foundation
import SwiftUI

public var test: Exercise = Exercise(name: "", desc: "", primaryMusclesWorked: [], secondaryMusclesWorked: [])

public let eArr = [
    //CHEST WITH DESCRIPTION
    Exercise(name: "Bench Press", desc: "-Lay on bench\n-Pull shoulder blades together and slightly arch back\n-Grip bar about 1-1.5x shoulder width\n-Breath air into the diaphragm and tighten abs\n-Lower bar to about the sternum, and touch the bar to your chest\n-Push bar back up\n-exhale, and repeat", primaryMusclesWorked: [Muscles.chest, Muscles.frontdeltoid], secondaryMusclesWorked: [Muscles.tricep]),
    Exercise(name: "Incline Dumbbell Press", desc: "-Set bench to about 30-45 degrees\n-Bring dumbbells to chest\n-As you press the dumbbells up, exhale\n-Breath air in, and bring dumbbells back down to chest", primaryMusclesWorked: [Muscles.chest, Muscles.frontdeltoid], secondaryMusclesWorked: [Muscles.tricep]),
    Exercise(name: "Dips", desc: "-Grip bars around shoulder width apart\n-Slightly lean forward\n-Slowly lower yourself until arm is about a 90 degree angle\n-Press back up and repeat", primaryMusclesWorked: [Muscles.chest, Muscles.frontdeltoid], secondaryMusclesWorked: [Muscles.tricep]),
    Exercise(name: "Standing Cable Chest Fly", desc: "-Grab handles on both sides\n-Slightly lean forward\n-Keep arms slightly bent and stiff\n-Push arms forward until they almost touch infront of you\n-Control handles back to starting position", primaryMusclesWorked: [Muscles.chest], secondaryMusclesWorked: [Muscles.frontdeltoid]),
    
    //CHEST WITHOUT DESCRIPTION
    
    //SHOULDER WITH DESCRIPTION
    Exercise(name: "Overhead Press", desc: "-On a rack, place the barbell a bit below shoulder height\n-Grip the bar just wider than shoulder width apart, and get your elbows underneath the bar\n-Unrack the bar and step back\n-Tighten glutes and brace core\n-Press the bar straight up, while getting under the bar\n-Bring the bar back down to touch the top of the chest", primaryMusclesWorked: [Muscles.frontdeltoid], secondaryMusclesWorked: [Muscles.lateraldeltoid, Muscles.tricep]),
    Exercise(name: "Seated Dumbbell Shoulder Press", desc: "-Grab dumbbells and find a bench with back support\n-Bring dumbbells to shoulders, with forearms stacked under the weight\n-Brace and press the dumbbells up\n-Bring the weight back to the shoulder and repeat", primaryMusclesWorked: [Muscles.frontdeltoid], secondaryMusclesWorked: [Muscles.tricep, Muscles.lateraldeltoid]),
    Exercise(name: "Dumbbell Lateral Raise", desc: "-Hold dumbbells by side with slightly bent and stiff arms\n-Raise dumbbells to the side until horizontal, almost as if pouring a watering can\n-Lower dumbbells back to side and repeat", primaryMusclesWorked: [Muscles.lateraldeltoid], secondaryMusclesWorked: [Muscles.frontdeltoid]),
    Exercise(name: "Reverse Dumbbell Fly", desc: "-Keeping a neutral back, lean forward and let dumbbells hang\n-Raise dumbbells up to the sides, squeezing upper back together\n-With control, let the dumbbells decline back to hanging", primaryMusclesWorked: [Muscles.reardeltoid, Muscles.rotatorcuff], secondaryMusclesWorked: [Muscles.trapezius]),
    
    //SHOULDER WITHOUT DESCRIPTION
    
    //BACK WITH DESCRIPTION
    Exercise(name: "Deadlift", desc: "-Stand in front of bar to where the bar is over the center of your foot when standing straight up\n-Breath air into diaphragm and brace\n-Lean forward and grip bar\n-Keeping a completely straight back, lift the bar up, imagining your legs pushing the floor down\n-Press glutes forward at the top and lockout the lift\n-Exhale, then breath air back in and brace\n-With control lower bar to the ground and repeat", primaryMusclesWorked: [Muscles.glute, Muscles.lowback], secondaryMusclesWorked: [Muscles.quad, Muscles.hamstring, Muscles.adductor, Muscles.trapezius, Muscles.forearmflexor]),
    Exercise(name: "Lat Pulldown", desc: "-Sit on the seat, with legs under the supports\n-Grip the bar with palms facing forward\n-Pull the bar to chest while squeezing shoulder blades together\n-Control the bar back up and repeat", primaryMusclesWorked: [Muscles.lat], secondaryMusclesWorked: [Muscles.reardeltoid, Muscles.bicep]),
    Exercise(name: "Pullup", desc: "-Grip the pullup bar with palms facing forward and completely hanging\n-Without rocking, pull body up until your chin is over the bar\n-Control yourself back down until you reach a dead hang and repeat", primaryMusclesWorked: [Muscles.lat], secondaryMusclesWorked: [Muscles.reardeltoid, Muscles.bicep]),
    Exercise(name: "Barbell Row", desc: "-Grip the bar with palm facing towards you\n-Bend over and brace, keeping a neutral back throughout the movement\n-Driving elbows back, pull the bar up towards your sternum, or whatever is comfortable\n-Lower the bar back down with control", primaryMusclesWorked: [Muscles.lat, Muscles.trapezius, Muscles.reardeltoid], secondaryMusclesWorked: [Muscles.bicep, Muscles.lowback]),
    
    //BACK WITHOUT DESCRIPTION
    
    Exercise(name: "Dumbbell Row", desc: "", primaryMusclesWorked: [Muscles.lat, Muscles.trapezius, Muscles.reardeltoid], secondaryMusclesWorked: [Muscles.bicep]),
    
    //BICEP WITH DESCRIPTION
    
    Exercise(name: "Barbell Curl", desc: "-Grip barbell with underhand grip\n-Keep elbows locked in place while bending them to lift the barbell up\n-Control the barbell back all the way down\n-Repeat process, avoiding unnecessary movement like swinging", primaryMusclesWorked: [Muscles.bicep], secondaryMusclesWorked: []),
    Exercise(name: "Dumbbell Curl", desc: "-Grip Dumbbell with underhand grip\n-Keep elbows locked in place while bending them to lift the dumbbell up\n-Control the dumbbell back all the way down\n-Repeat process, avoiding unnecessary movement like swinging", primaryMusclesWorked: [Muscles.bicep], secondaryMusclesWorked: []),
    Exercise(name: "Hammer Curl", desc: "-Grip Dumbbell in a neutral grip, so the the dumbbells are parallel to eachother\n-Keep elbows locked in place while bending them to lift the dumbbell up\n-Control the dumbbell back all the way down\n-Repeat process, avoiding unnecessary movement like swinging", primaryMusclesWorked: [Muscles.bicep], secondaryMusclesWorked: [Muscles.forearmflexor]),
    
    //BICEP WITHOUT DESCRIPTION
    
    //TRICEP WITH DESCRIPTION
    
    //TRICEP WITHOUT DESCRIPTION
    
    Exercise(name: "Barbell Skull-Crusher", desc: "", primaryMusclesWorked: [Muscles.tricep], secondaryMusclesWorked: []),
    Exercise(name: "Overhead Cable Tricep Extensions", desc: "", primaryMusclesWorked: [Muscles.tricep], secondaryMusclesWorked: []),
    Exercise(name: "Tricep Pushdown", desc: "", primaryMusclesWorked: [Muscles.tricep], secondaryMusclesWorked: []),
    Exercise(name: "Close-Grip Bench Press", desc: "", primaryMusclesWorked: [Muscles.tricep], secondaryMusclesWorked: [Muscles.frontdeltoid, Muscles.chest]),
    
    //QUADS WITH DESCRIPTION
    
    //QUADS WITHOUT DESCRIPTION
    Exercise(name: "Squat", desc: "", primaryMusclesWorked: [Muscles.quad, Muscles.glute, Muscles.lowback, Muscles.hamstring], secondaryMusclesWorked: [Muscles.adductor, Muscles.lowback, Muscles.calf]),
    Exercise(name: "Hack Squat", desc: "", primaryMusclesWorked: [Muscles.quad, Muscles.glute], secondaryMusclesWorked: [Muscles.adductor]),
    Exercise(name: "Leg Extension", desc: "", primaryMusclesWorked: [Muscles.quad], secondaryMusclesWorked: []),
    Exercise(name: "Bulgerian Split Squat", desc: "", primaryMusclesWorked: [Muscles.quad, Muscles.glute], secondaryMusclesWorked: [Muscles.adductor]),
    
    //HAMSTRING WITH DESCRIPTION
    
    //HAMSTRING WITHOUT DESCRIPTION
    Exercise(name: "Seated Leg Curl", desc: "", primaryMusclesWorked: [Muscles.hamstring], secondaryMusclesWorked: []),
    Exercise(name: "Lying Leg Curl", desc: "", primaryMusclesWorked: [Muscles.hamstring], secondaryMusclesWorked: []),
    Exercise(name: "Romanian Deadlift", desc: "", primaryMusclesWorked: [Muscles.hamstring, Muscles.glute, Muscles.lowback], secondaryMusclesWorked: [Muscles.adductor, Muscles.trapezius, Muscles.forearmflexor]),
    
    //GLUTES WITH DESCRIPTION
    
    //GLUTES WITHOUT DESCRIPTION
    Exercise(name: "Hip Thrust", desc: "", primaryMusclesWorked: [Muscles.glute], secondaryMusclesWorked: [Muscles.adductor]),
    
    //ABS WITH DESCRIPTION
    
    //ABS WITHOUT DESCRIPTION
    Exercise(name: "Cable Crunch", desc: "", primaryMusclesWorked: [Muscles.abdominal], secondaryMusclesWorked: [Muscles.oblique]),
    Exercise(name: "Hanging Leg Raise", desc: "", primaryMusclesWorked: [Muscles.abdominal], secondaryMusclesWorked: [Muscles.oblique]),
    Exercise(name: "High to Low Wood Chop", desc: "", primaryMusclesWorked: [Muscles.oblique], secondaryMusclesWorked: [Muscles.abdominal]),
    Exercise(name: "Crunch", desc: "", primaryMusclesWorked: [Muscles.abdominal], secondaryMusclesWorked: [Muscles.oblique]),
    
    //CALVES WITH DESCRIPTION
    
    //CALVES WITHOUT DESCRIPTION
    Exercise(name: "Standing Calf Raise", desc: "", primaryMusclesWorked: [Muscles.calf], secondaryMusclesWorked: []),
    Exercise(name: "Seated Calf Raise", desc: "", primaryMusclesWorked: [Muscles.calf], secondaryMusclesWorked: [])
    
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
