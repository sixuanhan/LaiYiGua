import SwiftUI
import FirebaseAI

struct GuaDetailView: View {
    let guaName: String
    let guaURL: URL
    let changingYaoPositions: [Int]
    let originalYao: [Int]
    let question: String
    let showSaveButton: Bool
    let onSaveAndExit: (() -> Void)?

    @State private var content: String = "加载中..."
    @State private var yaoContents: [Int: String] = [:]
    @State private var interpretation: (strategy: String, content: String) = ("策略加载中...", "内容加载中...")
    @State private var showSaveAlert = false
    @State private var aiInterpretation: String = ""
    @State private var isLoadingAI: Bool = false
    @State private var showAIInterpretation: Bool = false
    @EnvironmentObject private var recordManager: DivinationRecordManager
    @Environment(\.dismiss) private var dismiss

    // 便利初始化器，用于新的占卜结果（需要保存按钮）
    init(guaName: String, guaURL: URL, changingYaoPositions: [Int], originalYao: [Int], question: String, onSaveAndExit: (() -> Void)? = nil) {
        self.guaName = guaName
        self.guaURL = guaURL
        self.changingYaoPositions = changingYaoPositions
        self.originalYao = originalYao
        self.question = question
        self.showSaveButton = true
        self.onSaveAndExit = onSaveAndExit
    }
    
    // 完整初始化器，用于历史记录（可选择是否显示保存按钮）
    init(guaName: String, guaURL: URL, changingYaoPositions: [Int], originalYao: [Int], question: String, showSaveButton: Bool, onSaveAndExit: (() -> Void)? = nil) {
        self.guaName = guaName
        self.guaURL = guaURL
        self.changingYaoPositions = changingYaoPositions
        self.originalYao = originalYao
        self.question = question
        self.showSaveButton = showSaveButton
        self.onSaveAndExit = onSaveAndExit
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
                
                // AI解卦按钮
                if !isLoadingAI && interpretation.content != "内容加载中..." {
                    Button(action: {
                        Task {
                            await generateAIInterpretation()
                        }
                    }) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                            Text("AI解卦")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.top)
                }
                
                // AI加载状态
                if isLoadingAI {
                    ProgressView("AI正在解卦中...")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                // AI解卦结果
                if showAIInterpretation && !aiInterpretation.isEmpty {
                    Divider()
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.purple)
                            Text("AI解卦")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                        }
                        
                        // 解析并显示AI回复
                        let parsedContent = parseAIResponse(aiInterpretation)
                        
                        // 一句话总结（重点显示）
                        if !parsedContent.summary.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("核心建议")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.purple)
                                
                                Text(parsedContent.summary)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding()
                                    .background(Color.purple.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                        
                        // 详细解析
                        if !parsedContent.details.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("详细解析")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.purple)
                                
                                Text(parsedContent.details)
                                    .font(.body)
                                    .lineSpacing(4)
                            }
                        }
                        
                        // 如果解析失败，显示原始内容
                        if parsedContent.summary.isEmpty && parsedContent.details.isEmpty {
                            Text(aiInterpretation)
                                .font(.body)
                                .lineSpacing(4)
                        }
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(guaName)
        .toolbar {
            if showSaveButton {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(onSaveAndExit != nil ? "保存并退出" : "保存") {
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
        
        if let onSaveAndExit = onSaveAndExit {
            // 如果有保存并退出回调，直接执行
            onSaveAndExit()
        } else {
            // 否则显示保存成功提示
            showSaveAlert = true
        }
    }
    
    func generateAIInterpretation() async {
        await MainActor.run {
            isLoadingAI = true
            showAIInterpretation = false
        }
        
        do {
            let ai = FirebaseAI.firebaseAI(backend: .googleAI())
            let client = ai.generativeModel(modelName: "gemini-2.0-flash")
            
            // 生成卦相描述
            let guaDescription = generateGuaDescription()
            
            let prompt = """
            你是一位精通周易占卜的专家。请根据以下信息为用户提供具体的解卦建议：
            
            用户问题：\(question)
            
            卦象信息：\(guaName)
            \(guaDescription)
            
            解卦策略：\(interpretation.strategy)
            
            传统解释概要：\(String(interpretation.content.prefix(500)))...
            
            请按以下格式回复：
            
            【一句话总结】
            [用一句话概括对用户问题的核心建议，20字以内]
            
            【详细解析】
            请结合用户的具体问题和卦象，提供：
            1. 针对用户问题的直接建议
            2. 当前形势的分析
            3. 行动指导和注意事项
            4. 时机把握的建议
            
            请用易懂的现代语言解释，避免过于深奥的古文，让用户能够理解并应用到实际生活中。
            详细解析部分字数控制在300-500字之间。
            注意：不要在回复中使用markdown格式符号（如**、#等）。
            """
            
            let response = try await client.generateContent(prompt)
            let responseText = response.text ?? "AI解卦暂时无法生成，请稍后再试。"
            
            await MainActor.run {
                self.aiInterpretation = responseText
                self.isLoadingAI = false
                self.showAIInterpretation = true
            }
        } catch {
            await MainActor.run {
                self.aiInterpretation = "AI解卦出现错误：\(error.localizedDescription)"
                self.isLoadingAI = false
                self.showAIInterpretation = true
            }
        }
    }
    
    private func parseAIResponse(_ response: String) -> (summary: String, details: String) {
        let lines = response.components(separatedBy: .newlines)
        var summary = ""
        var details = ""
        var currentSection = ""
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmed.contains("【一句话总结】") {
                currentSection = "summary"
                continue
            } else if trimmed.contains("【详细解析】") {
                currentSection = "details"
                continue
            }
            
            if !trimmed.isEmpty {
                switch currentSection {
                case "summary":
                    if summary.isEmpty {
                        summary = trimmed
                    }
                case "details":
                    if !details.isEmpty {
                        details += "\n"
                    }
                    details += trimmed
                default:
                    // 如果没有找到标准格式，将所有内容作为详细解析
                    if !details.isEmpty {
                        details += "\n"
                    }
                    details += trimmed
                }
            }
        }
        
        return (summary: summary, details: details)
    }
    
    private func generateGuaDescription() -> String {
        var description = ""
        
        // 显示原始爻象
        description += "原始爻象（从下至上）：\n"
        for (index, yao) in originalYao.enumerated() {
            let position = index + 1
            let yaoType = (yao == 6 || yao == 8) ? "阴爻" : "阳爻"
            let isChanging = changingYaoPositions.contains(position) ? "（变爻）" : ""
            description += "第\(position)爻：\(yaoType)\(isChanging)\n"
        }
        
        // 显示变爻信息
        if !changingYaoPositions.isEmpty {
            description += "\n变爻位置：第\(changingYaoPositions.map(String.init).joined(separator: "、"))爻"
        } else {
            description += "\n静卦（无变爻）"
        }
        
        return description
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
