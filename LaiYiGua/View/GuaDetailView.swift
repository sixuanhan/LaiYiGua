import SwiftUI

struct GuaDetailView: View {
    let guaName: String
    let guaURL: URL
    let changingYaoPositions: [Int]
    let originalYao: [Int]

    @State private var content: String = "加载中..."
    @State private var yaoContents: [Int: String] = [:]
    @State private var interpretation: (strategy: String, content: String) = ("策略加载中...", "内容加载中...")

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
        .task {
            await loadContent()
            await loadInterpretation()
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
            } else {
                self.content = "❌ 无法读取网页内容。"
                self.yaoContents = [:]
            }
        } catch {
            self.content = "❌ 网络请求失败：\(error.localizedDescription)"
            self.yaoContents = [:]
        }
    }

    func loadInterpretation() async {
        let result = await InterpretationStrategy.getStrategy(
            changingYaoPositions: changingYaoPositions,
            yaoContents: yaoContents,
            content: content,
            guaName: guaName,
            originalYao: originalYao
        )
        DispatchQueue.main.async {
            self.interpretation = result
        }
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
                originalYao: [9, 9, 9, 9, 9, 9]
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
                originalYao: [9, 6, 9, 9, 8, 9]
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
                originalYao: [9, 6, 9, 9, 6, 9]
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
                originalYao: [6, 8, 9, 8, 8, 9]
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
                originalYao: [6, 9, 8, 6, 9, 8]
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
                originalYao: [6, 6, 6, 6, 8, 6]
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
                originalYao: [9, 9, 9, 9, 9, 9]
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
                originalYao: [6, 6, 6, 6, 6, 6]
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
                originalYao: [9, 6, 9, 9, 8, 9]
            )
        }
        .tabItem {
            Text("6变爻(其他)")
        }
    }
}
