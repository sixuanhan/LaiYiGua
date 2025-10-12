//
//  ContentView.swift
//  LaiYiGua
//
//  Created by xuanxuan on 10/11/25.
//

import SwiftUI
import CoreData

// 占卜页面和历史记录页面的占位符已在各自文件实现
// ContentView 可暂时移除或保留做后续扩展

struct ContentView: View {
    @StateObject private var recordManager = DivinationRecordManager()
    
    var body: some View {
        TabView {
            NavigationView {
                DivinationView()
            }
            .tabItem {
                Label("占卜", systemImage: "sparkles")
            }
            
            NavigationView {
                HistoryView()
            }
            .tabItem {
                Label("历史记录", systemImage: "clock")
            }
        }
        .environmentObject(recordManager)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
