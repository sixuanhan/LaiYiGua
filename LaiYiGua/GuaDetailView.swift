import SwiftUI

struct GuaDetailView: View {
    let guaName: String
    let guaURL: URL
    let changingYaoPositions: [Int]

    @State private var content: String = "加载中..."
    @State private var yaoContents: [Int: String] = [:]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 显示变爻信息
                ChangingYaoInfoView(changingYaoPositions: changingYaoPositions)
                
                Divider()
                
                // 解卦策略部分
                let interpretation = InterpretationStrategy.getStrategy(
                    changingYaoPositions: changingYaoPositions,
                    yaoContents: yaoContents,
                    content: content,
                    guaName: guaName
                )
                
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
}

#Preview {
    NavigationStack {
        GuaDetailView(
            guaName: "37. 风火家人",
            guaURL: URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/4176.html")!,
            changingYaoPositions: [2, 3]
        )
    }
}
