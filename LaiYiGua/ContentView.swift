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
    var body: some View {
        TabView {
            DivinationView()
                .tabItem {
                    Label("占卜", systemImage: "sparkles")
                }
            HistoryView()
                .tabItem {
                    Label("历史记录", systemImage: "clock")
                }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
