//
//  SwiftUIView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 4/17/24.
//

import SwiftUI
import CoreData

struct SwiftUIView: View {
    
    @FetchRequest(fetchRequest: CDWorkoutRecord.fetch(), animation: .bouncy)
    var workoutRecords: FetchedResults<CDWorkoutRecord>
    
    var body: some View {
        VStack {
            ForEach(workoutRecords) { record in
                Text("\(record.date)")
            }
        }
    }
}

#Preview {
    SwiftUIView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
