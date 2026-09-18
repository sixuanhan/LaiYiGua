import SwiftUI

struct CollapsibleContentView: View {
    let title: String
    let content: String
    let isExpandedByDefault: Bool
    @State private var isExpanded: Bool
    
    init(title: String, content: String, isExpandedByDefault: Bool = false) {
        self.title = title
        self.content = content
        self.isExpandedByDefault = isExpandedByDefault
        self._isExpanded = State(initialValue: isExpandedByDefault)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏（可点击折叠/展开）
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 内容区域（可折叠）
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ParsedContentView(content: content)
                }
                .padding(16)
                .background(Color(.systemBackground))
//                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            CollapsibleContentView(
                title: "解卦策略",
                content: "六爻不变 - 用本卦卦辞解卦\n\n依据本卦卦辞来解卦。\n\n【解卦要点】\n本卦卦辞为主要依据，分析所问之事的吉凶",
                isExpandedByDefault: true
            )
            
            CollapsibleContentView(
                title: "传统解释",
                content: "卦原文\n乾：元，亨，利，贞。\n\n白话文解释\n乾卦象征天，具有元始、亨通、和谐、贞正四德。"
            )
            
            CollapsibleContentView(
                title: "变卦详解",
                content: "变卦：坤为地\n\n卦辞：坤：元，亨，利牝马之贞。"
            )
        }
        .padding()
    }
}
