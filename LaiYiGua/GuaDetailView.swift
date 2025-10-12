import SwiftUI

struct GuaDetailView: View {
    let guaName: String
    let guaURL: URL

    @State private var content: String = "加载中..."

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(parseContent(content), id: \.id) { item in
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
                let extracted = extractMainContent(from: html)
                DispatchQueue.main.async {
                    self.content = extracted
                }
            } else {
                self.content = "❌ 无法读取网页内容。"
            }
        } catch {
            self.content = "❌ 网络请求失败：\(error.localizedDescription)"
        }
    }

    func extractMainContent(from html: String) -> String {
        // 匹配从 "x卦原文" 到 "第X卦的哲学含义" 之间的内容（不包括结束标题）
        let pattern = "(.{0,10}卦原文[\\s\\S]*?)第.*?卦的哲学含义"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)) else {
            return "未找到指定内容段落。"
        }

        if let range = Range(match.range(at: 1), in: html) {
            let raw = String(html[range])
            // 去除 HTML 标签
            var cleaned = raw
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .replacingOccurrences(of: "&nbsp;", with: " ")
                .replacingOccurrences(of: "&ldquo;", with: "")
                .replacingOccurrences(of: "&rdquo;", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            return cleaned
        } else {
            return "未找到匹配区间。"
        }
    }
    
    func parseContent(_ content: String) -> [ContentItem] {
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

struct ContentItem {
    let id = UUID()
    let text: String
    let isTitle: Bool
}

#Preview {
    NavigationStack {
        GuaDetailView(guaName: "乾卦", guaURL: URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/4103.html")!)
    }
}
