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
    @State private var selectedTab = 0
    @State private var shouldResetDivination = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                DivinationView(shouldReset: $shouldResetDivination)
            }
            .tabItem {
                Label("占卜", systemImage: "sparkles")
            }
            .tag(0)

            NavigationView {
                HistoryView()
            }
            .tabItem {
                Label("历史记录", systemImage: "clock")
            }
            .tag(1)
        }
        .environmentObject(recordManager)
        .environmentObject(NavigationManager(
            switchToHistoryTab: {
                selectedTab = 1
                shouldResetDivination = true
            }
        ))
    }
}

// 导航管理器
class NavigationManager: ObservableObject {
    let switchToHistoryTab: () -> Void
    
    init(switchToHistoryTab: @escaping () -> Void) {
        self.switchToHistoryTab = switchToHistoryTab
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
