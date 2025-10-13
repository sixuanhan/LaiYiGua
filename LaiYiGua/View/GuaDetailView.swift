import SwiftUI

struct GuaDetailView: View {
    let guaName: String
    let guaURL: URL
    let changingYaoPositions: [Int]
    let originalYao: [Int]
    let question: String
    let showSaveButton: Bool

    @State private var content: String = "加载中..."
    @State private var yaoContents: [Int: String] = [:]
    @State private var interpretation: (strategy: String, content: String) = ("策略加载中...", "内容加载中...")
    @State private var showSaveAlert = false
    @EnvironmentObject private var recordManager: DivinationRecordManager
    @Environment(\.dismiss) private var dismiss

    // 便利初始化器，用于新的占卜结果（需要保存按钮）
    init(guaName: String, guaURL: URL, changingYaoPositions: [Int], originalYao: [Int], question: String) {
        self.guaName = guaName
        self.guaURL = guaURL
        self.changingYaoPositions = changingYaoPositions
        self.originalYao = originalYao
        self.question = question
        self.showSaveButton = true
    }
    
    // 完整初始化器，用于历史记录（可选择是否显示保存按钮）
    init(guaName: String, guaURL: URL, changingYaoPositions: [Int], originalYao: [Int], question: String, showSaveButton: Bool) {
        self.guaName = guaName
        self.guaURL = guaURL
        self.changingYaoPositions = changingYaoPositions
        self.originalYao = originalYao
        self.question = question
        self.showSaveButton = showSaveButton
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 解卦策略部分
                InterpretationStrategyView(
                    strategy: interpretation.strategy,
                    content: interpretation.content
                )
                
                Divider()
                
                // 解析后的内容显示
                ParsedContentView(content: content)
            }
            .padding()
        }
        .navigationTitle(guaName)
        .toolbar {
            if showSaveButton {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveRecord()
                    }
                    .disabled(interpretation.content == "内容加载中..." || content == "加载中...")
                }
            }
        }
        .alert("保存成功", isPresented: $showSaveAlert) {
            Button("确定") { }
        } message: {
            Text("占卜记录已保存到历史页面")
        }
        .task {
            await loadContent()
        }
    }

    func loadContent() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: guaURL)
            if let html = String(data: data, encoding: .utf8) {
                let content = HTMLContentExtractor.extractMainContent(from: html)
                let yaos = HTMLContentExtractor.extractAllYao(from: html)
                DispatchQueue.main.async {
                    self.content = content
                    self.yaoContents = yaos
                }
                // 在 content 和 yaoContents 更新后再加载解释
                await loadInterpretation()
            } else {
                DispatchQueue.main.async {
                    self.content = "❌ 无法读取网页内容。"
                    self.yaoContents = [:]
                }
                await loadInterpretation()
            }
        } catch {
            DispatchQueue.main.async {
                self.content = "❌ 网络请求失败：\(error.localizedDescription)"
                self.yaoContents = [:]
            }
            await loadInterpretation()
        }
    }

    func loadInterpretation() async {
        // 获取当前的状态值
        let currentContent = await MainActor.run { content }
        let currentYaoContents = await MainActor.run { yaoContents }
        
        let result = await InterpretationStrategy.getStrategy(
            changingYaoPositions: changingYaoPositions,
            yaoContents: currentYaoContents,
            content: currentContent,
            guaName: guaName,
            originalYao: originalYao
        )
        
        await MainActor.run {
            self.interpretation = result
        }
    }
    
    func saveRecord() {
        let record = DivinationRecord(
            question: question,
            guaName: guaName,
            guaURL: guaURL,
            originalYao: originalYao,
            changingYaoPositions: changingYaoPositions,
            interpretation: interpretation.content,
            strategy: interpretation.strategy
        )
        recordManager.saveRecord(record)
        showSaveAlert = true
    }
}

#Preview("变爻测试") {
    TabView {
        // 0个变爻 - 静卦
        NavigationStack {
            GuaDetailView(
                guaName: "1. 乾为天",
                guaURL: URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/4103.html")!,
                changingYaoPositions: [],
                originalYao: [7,7,7,7,7,7],
                question: "我是否应该在年底前换工作？"
            )
        }
        .tabItem {
            Text("0变爻")
        }

        NavigationStack {
            GuaDetailView(
                guaName: "2. 坤为地",
                guaURL: URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/4105.html")!,
                changingYaoPositions: [],
                originalYao: [8,8,8,8,8,8],
                question: "我想要投资房产是否合适？"
            )
        }
        .tabItem {
            Text("0变爻")
        }

        // 1个变爻
        NavigationStack {
            GuaDetailView(
                guaName: "37. 风火家人",
                guaURL: URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/4176.html")!,
                changingYaoPositions: [3],
                originalYao: [9, 6, 9, 9, 8, 9],
                question: "我决定与家人和解，时机是否合适？"
            )
        }
        .tabItem {
            Text("1变爻")
        }
        
        // 2个变爻
        NavigationStack {
            GuaDetailView(
                guaName: "37. 风火家人",
                guaURL: URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/4176.html")!,
                changingYaoPositions: [2, 5],
                originalYao: [9, 6, 9, 9, 6, 9],
                question: "我想要调整家庭关系，应该采取什么策略？"
            )
        }
        .tabItem {
            Text("2变爻")
        }
        
        // 3个变爻
        NavigationStack {
            GuaDetailView(
                guaName: "8. 水地比",
                guaURL: URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/4111.html")!,
                changingYaoPositions: [1, 3, 6],
                originalYao: [6, 8, 9, 8, 8, 9],
                question: "我决定与朋友合作创业是否明智？"
            )
        }
        .tabItem {
            Text("3变爻")
        }
        
        // 4个变爻
        NavigationStack {
            GuaDetailView(
                guaName: "29. 坎为水",
                guaURL: URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/4168.html")!,
                changingYaoPositions: [1, 2, 4, 5],
                originalYao: [6, 9, 8, 6, 9, 8],
                question: "我想要度过目前的困难时期，需要采取什么行动？"
            )
        }
        .tabItem {
            Text("4变爻")
        }
        
        // 5个变爻
        NavigationStack {
            GuaDetailView(
                guaName: "2. 坤为地",
                guaURL: URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/4105.html")!,
                changingYaoPositions: [1, 2, 3, 4, 6],
                originalYao: [6, 6, 6, 6, 8, 6],
                question: "我决定保持谦逊态度面对当前挑战是否正确？"
            )
        }
        .tabItem {
            Text("5变爻")
        }
        
        // 6个变爻 - 乾卦（用九）
        NavigationStack {
            GuaDetailView(
                guaName: "1. 乾为天",
                guaURL: URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/4103.html")!,
                changingYaoPositions: [1, 2, 3, 4, 5, 6],
                originalYao: [9, 9, 9, 9, 9, 9],
                question: "我想要在事业上取得突破性进展是否合适？"
            )
        }
        .tabItem {
            Text("6变爻(乾)")
        }
        
        // 6个变爻 - 坤卦（用六）
        NavigationStack {
            GuaDetailView(
                guaName: "2. 坤为地",
                guaURL: URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/4105.html")!,
                changingYaoPositions: [1, 2, 3, 4, 5, 6],
                originalYao: [6, 6, 6, 6, 6, 6],
                question: "我决定以柔克刚的方式处理当前局面是否明智？"
            )
        }
        .tabItem {
            Text("6变爻(坤)")
        }
        
        // 6个变爻 - 其他卦
        NavigationStack {
            GuaDetailView(
                guaName: "37. 风火家人",
                guaURL: URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/4176.html")!,
                changingYaoPositions: [1, 2, 3, 4, 5, 6],
                originalYao: [9, 6, 9, 9, 8, 9],
                question: "我想要彻底改变家庭现状，时机是否成熟？"
            )
        }
        .tabItem {
            Text("6变爻(其他)")
        }
    }
    .environmentObject(DivinationRecordManager())
}
