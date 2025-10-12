import SwiftUI

struct ParsedContentView: View {
    let content: String
    
    var body: some View {
        ForEach(parseMainContent(content), id: \.id) { item in
            if item.isTitle {
                Text(item.text)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 8)
            } else {
                Text(item.text)
                    .font(.body)
            }
        }
    }
    
    private func parseMainContent(_ content: String) -> [ContentItem] {
        let lines = content.components(separatedBy: .newlines)
        var items: [ContentItem] = []
        let titles = ["卦原文", "白话文解释", "《断易天机》解", "北宋易学家邵雍解", "台湾国学大儒傅佩荣解", "传统解卦"]
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if !trimmedLine.isEmpty {
                let isTitle = titles.contains { title in
                    trimmedLine.contains(title)
                }
                items.append(ContentItem(text: trimmedLine, isTitle: isTitle))
            }
        }
        
        return items
    }
}

#Preview {
    ScrollView {
        ParsedContentView(content: "卦原文\n这是卦原文内容\n白话文解释\n这是白话文解释内容")
            .padding()
    }
}
