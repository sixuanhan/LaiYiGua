import Foundation

class HTMLContentExtractor {
    
    // 通用的HTML内容提取函数
    static func extractWithPattern(from html: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)) else {
            return nil
        }
        
        if let range = Range(match.range(at: 1), in: html) {
            let raw = String(html[range])
            // 去除 HTML 标签并清理特殊字符
            let cleaned = raw
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .replacingOccurrences(of: "&nbsp;", with: " ")
                .replacingOccurrences(of: "&ldquo;", with: "“")
                .replacingOccurrences(of: "&rdquo;", with: "”")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            return cleaned
        }
        
        return nil
    }
    
    static func extractMainContent(from html: String) -> String {
        // 匹配从 "x卦原文" 到 "第X卦的哲学含义" 之间的内容（不包括结束标题）
        let pattern = "(.{0,10}卦原文[\\s\\S]*?)第.*?卦的哲学含义"
        return extractWithPattern(from: html, pattern: pattern) ?? "未找到指定内容段落。"
    }
    
    /// 从周易网页 HTML 中提取所有爻辞（每个爻位都尝试搜索"九"和"六"两种可能性）
    /// 返回 [爻序: 内容]，例如 [1: "初九爻辞…", 2: "九二爻辞…", ...]
    static func extractAllYao(from html: String) -> [Int: String] {
        var results: [Int: String] = [:]
        
        // 定义每个爻位的两种可能性（阳爻和阴爻）
        let yaoNames = [
            ["初九", "初六"],   // 第一爻
            ["九二", "六二"],   // 第二爻
            ["九三", "六三"],   // 第三爻
            ["九四", "六四"],   // 第四爻
            ["九五", "六五"],   // 第五爻
            ["上九", "上六"]    // 第六爻
        ]
        
        for i in 0..<6 {
            let yaoPosition = i + 1
            var foundContent: String? = nil
            
            // 尝试搜索阳爻和阴爻两种可能性
            for yaoName in yaoNames[i] {
                let start = yaoName + "爻辞"
                let next = yaoName + "变卦"
                
                let pattern = "(" + NSRegularExpression.escapedPattern(for: start) + "[\\s\\S]*?)(?=" + NSRegularExpression.escapedPattern(for: next) + ")"
                
                if let content = extractWithPattern(from: html, pattern: pattern) {
                    foundContent = content
                    break // 找到了就不用继续搜索另一种可能性
                }
            }
            
            // 保存找到的内容，如果都没找到则显示错误信息
            results[yaoPosition] = foundContent ?? "[未找到第\(yaoPosition)爻内容]"
        }
        
        return results
    }
}
