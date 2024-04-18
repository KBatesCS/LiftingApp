//
//  SwiftUIView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 4/17/24.
//

import SwiftUI
import CoreData

struct SwiftUIView: View {
    
    @FetchRequest(fetchRequest: CDSetRecord.fetch()) var workoutRecords: FetchedResults<CDSetRecord>
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SwiftUIView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
