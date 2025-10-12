//  DivinationView.swift
//  LaiYiGua
//  占卜页面 Placeholder
import SwiftUI
import FirebaseAI

final class DivinationViewModel: ObservableObject {
    @Published var question: String = ""
    @Published var answer: String = ""
    @Published var isLoading: Bool = false
    private var client: GenerativeModel?

    init() {
        setup()
    }

    func setup() {
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        client = ai.generativeModel(modelName: "gemini-2.0-flash")
    }

    func divine() {
        guard let client = client else {
            answer = "Error: Gemini client not initialized"
            return
        }
        isLoading = true
        let prompt = """
        你是一位精通周易的占卜师。请用周易卦象的方式，解答用户提出的问题：\n"
        "问题：\"\(question)\"\n"
        "请以简洁、专业的语气，结合卦象和易经原理，给出详细解读和建议。无需客套话。\n"
        """
        Task {
            do {
                let response = try await client.generateContent(prompt)
                DispatchQueue.main.async {
                    self.answer = response.text ?? "未获得有效回复"
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.answer = "Error: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

struct DivinationView: View {
    @StateObject private var viewModel = DivinationViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("占卜页面")
                .font(.largeTitle)
                .padding(.top)
            TextField("请输入你想要占卜的问题", text: $viewModel.question)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            Button(action: {
                viewModel.divine()
            }) {
                Text("占卜")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            if viewModel.isLoading {
                ProgressView("正在生成占卜结果...")
                    .padding()
            } else if !viewModel.answer.isEmpty {
                ScrollView {
                    Text(viewModel.answer)
                        .padding()
                }
            }
            Spacer()
        }
    }
}

#Preview {
    DivinationView()
}
