import SwiftUI

struct InterpretationStrategyView: View {
    let strategy: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("解卦策略")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(strategy)
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.bottom, 4)
            
            Text(content)
                .font(.body)
                .lineLimit(nil)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    InterpretationStrategyView(
        strategy: "一个变爻 - 用本卦变爻爻辞解卦",
        content: "用本卦第2爻的爻辞来解卦。\n\n【解卦要点】\n以本卦变爻的爻辞为根据进行推演。"
    )
    .padding()
}
