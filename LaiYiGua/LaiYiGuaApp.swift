//
//  LaiYiGuaApp.swift
//  LaiYiGua
//
//  Created by xuanxuan on 10/11/25.
//

import SwiftUI

@main
struct LaiYiGuaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
