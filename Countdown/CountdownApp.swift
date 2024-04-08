//
//  CountdownApp.swift
//  Countdown
//
//  Created by Hilal on 29.03.2024.
//

import SwiftUI

@main
struct CountdownApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
