//  DivinationView.swift
//  LaiYiGua
import SwiftUI
import FirebaseAI

final class DivinationViewModel: ObservableObject {
    @Published var question: String = ""
    @Published var refinedQuestions: [String] = []
    @Published var selectedQuestion: String = ""
    @Published var isLoading: Bool = false
    @Published var duplicateWarning: String? = nil
    private var client: GenerativeModel?
    private var recordManager: DivinationRecordManager?

    init() {
        setup()
    }
    
    func setRecordManager(_ manager: DivinationRecordManager) {
        self.recordManager = manager
    }

    func setup() {
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        client = ai.generativeModel(modelName: "gemini-2.0-flash")
    }

    func refineQuestion() {
        guard let client = client else {
            refinedQuestions = ["Error: Gemini client not initialized"]
            return
        }
        isLoading = true
        duplicateWarning = nil
        
        // 获取最近3个月的历史问题
        let recentQuestions = getRecentQuestions()
        let historySection = recentQuestions.isEmpty ? "" : """
        
        最近3个月的历史问题：
        \(recentQuestions.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        请判断当前问题是否与历史问题重复或相似。如果重复，请在回复最后添加一行：
        【重复警告】这个问题与历史问题相似，可能影响占卜准确性。
        """
        
        let prompt = """
        你是一位精通周易占卜的专家。请将用户的问题修正为更适合易经占卜的形式。
        
        好的占卜问题必须包含以下元素：
        1. 主辞明确：事主是你自己，还是代某人筮问（通常是求卦者本人）
        2. 动辞明确：事主到底想做什么事？
        3. 时间地点：必要时要说清楚
        4. 有自由意志的选择：最好以「我决定…」、「我想要…」为开头
        5. 问题要具体明确，当事者要有所决定（可能决定，非最终决定）
        
        用户原问题："\(question)"\(historySection)
        
        请提供3个不同的修正版本，每个版本都要符合上述要求，格式如下：
        
        1. [修正问题1]
        
        2. [修正问题2]
        
        3. [修正问题3]
        
        如果存在重复问题，请在最后添加重复警告。
        """
        Task {
            do {
                let response = try await client.generateContent(prompt)
                let responseText = response.text ?? "未获得有效回复"
                let (questions, warning) = parseRefinedQuestions(from: responseText)
                DispatchQueue.main.async {
                    self.refinedQuestions = questions
                    self.duplicateWarning = warning
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.refinedQuestions = ["Error: \(error.localizedDescription)"]
                    self.isLoading = false
                }
            }
        }
    }
    
    private func parseRefinedQuestions(from text: String) -> ([String], String?) {
        let lines = text.components(separatedBy: .newlines)
        var questions: [String] = []
        var warning: String? = nil
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 检查是否包含重复警告
            if trimmed.contains("【重复警告】") {
                warning = trimmed.replacingOccurrences(of: "【重复警告】", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                continue
            }
            
            // 匹配 "1. 问题内容" 格式
            if let regex = try? NSRegularExpression(pattern: "^\\d+\\.\\s*(.+)$"),
               let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
               let range = Range(match.range(at: 1), in: trimmed) {
                let question = String(trimmed[range])
                if !question.isEmpty {
                    questions.append(question)
                }
            }
        }
        
        return (questions.isEmpty ? [text] : questions, warning)
    }
    
    private func getRecentQuestions() -> [String] {
        guard let recordManager = recordManager else { return [] }
        
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        
        return recordManager.records
            .filter { $0.date >= threeMonthsAgo }
            .sorted { $0.date > $1.date } // 最新的在前
            .prefix(10) // 最多取10个问题，避免prompt过长
            .map { $0.question }
    }
}

struct DivinationView: View {
    @StateObject private var viewModel = DivinationViewModel()
    @EnvironmentObject private var recordManager: DivinationRecordManager
    @Binding var shouldReset: Bool
    
    init(shouldReset: Binding<Bool> = .constant(false)) {
        self._shouldReset = shouldReset
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("开始占卜")
                    .font(.largeTitle)
                    .padding(.top)
                
                Text("提出一个合适的问题")
                    .font(.title)
                    .padding(.top)
                
                // 占卜问题纲领
                VStack(alignment: .leading, spacing: 12) {
                    Text("好的占卜问题必须包含：")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• **主辞明确**：事主是你自己，还是代某人筮问（通常是求卦者本人）")
                        Text("• **动辞明确**：事主到底想做什么事？")
                        Text("• **时间地点**：必要时要说清楚")
                        Text("• **有自由意志的选择**：最好以「我决定…」、「我想要…」为开头")
                        Text("• **具体明确**：当事者要有所决定（可能决定，非最终决定）")
                    }
                    .font(.body)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // 输入问题
                VStack(alignment: .leading, spacing: 8) {
                    Text("请输入你想要占卜的问题：")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextField("例如：我最近在考虑换工作...", text: $viewModel.question, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                        .padding(.horizontal)
                }
                
                // 修正问题按钮
                Button(action: {
                    viewModel.refineQuestion()
                }) {
                    Text("修正问题")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.question.isEmpty ? Color.gray : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(viewModel.question.isEmpty)
                .padding(.horizontal)
                
                // 加载状态
                if viewModel.isLoading {
                    ProgressView("正在修正问题...")
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                
                // 重复警告显示
                if let warning = viewModel.duplicateWarning {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("重复问题警告")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        Text(warning)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // 修正后的问题选择
                if !viewModel.refinedQuestions.isEmpty && !viewModel.isLoading {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("请选择一个修正后的问题：")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(Array(viewModel.refinedQuestions.enumerated()), id: \.offset) { index, question in
                            Button(action: {
                                viewModel.selectedQuestion = question
                            }) {
                                HStack {
                                    Image(systemName: viewModel.selectedQuestion == question ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(viewModel.selectedQuestion == question ? .blue : .gray)
                                    
                                    Text(question)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(viewModel.selectedQuestion == question ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                        
                        // 占卜按钮
                        if !viewModel.selectedQuestion.isEmpty {
                            NavigationLink(destination: SticksLayoutView(question: viewModel.selectedQuestion)
                                .toolbar(.hidden, for: .tabBar)) {
                                Text("开始占卜")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                    }
                }
                
                Spacer(minLength: 20)
            }
        }
        .onAppear {
            viewModel.setRecordManager(recordManager)
        }
        .onChange(of: shouldReset) { reset in
            if reset {
                // 重置所有状态
                viewModel.question = ""
                viewModel.refinedQuestions = []
                viewModel.selectedQuestion = ""
                viewModel.duplicateWarning = nil
                shouldReset = false
            }
        }
    }
}

#Preview {
    DivinationView()
}
