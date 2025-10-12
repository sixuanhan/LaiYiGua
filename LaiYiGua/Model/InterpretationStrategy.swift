import Foundation

class InterpretationStrategy {
    
    // 计算变卦的爻值数组（将变爻6<->9翻转）
    private static func calculateChangedYao(originalYao: [Int], changingPositions: [Int]) -> [Int] {
        var changedYao = originalYao
        for position in changingPositions {
            let index = position - 1 // 转换为0-based索引
            if index >= 0 && index < changedYao.count {
                let originalValue = changedYao[index]
                // 6变成9，9变成6，其他保持不变
                if originalValue == 6 {
                    changedYao[index] = 9
                } else if originalValue == 9 {
                    changedYao[index] = 6
                }
            }
        }
        return changedYao
    }
    
    // 从爻值数组生成卦名
    private static func generateGuaName(from yao: [Int]) -> String {
        // 这里需要使用与GuaResultView中相同的逻辑
        let inner = Array(yao[0...2])
        let outer = Array(yao[3...5])
        let innerName = yaoToGuaName(inner)
        let outerName = yaoToGuaName(outer)
        return getFullGuaName(inner: innerName, outer: outerName)
    }
    
    static func getStrategy(
        changingYaoPositions: [Int],
        yaoContents: [Int: String],
        content: String,
        guaName: String,
        originalYao: [Int]
    ) async -> (strategy: String, content: String) {
        
        let changingYaoCount = changingYaoPositions.count
        
        switch changingYaoCount {
        case 0:
            // 1.六爻不变，依据本卦卦辞来解卦
            return (
                strategy: "六爻不变 - 用本卦卦辞解卦",
                content: "依据本卦卦辞来解卦。\n\n【解卦要点】\n本卦卦辞为主要依据，分析所问之事的吉凶)"
            )
            
        case 1:
            // 2.卦中有一个变爻，就用这个本卦变爻的爻辞来解卦
            let position = changingYaoPositions.first ?? 1
            let yaoContent = yaoContents[position] ?? "[爻辞加载中...]"
            return (
                strategy: "一个变爻 - 用本卦变爻爻辞解卦",
                content: "用本卦第\(position)爻的爻辞来解卦。\n\n【解卦要点】\n以本卦变爻的爻辞为根据进行推演。\n\n【爻辞内容】\n\(yaoContent)"
            )
            
        case 2:
            // 3.卦中有两个变爻，用这两个本卦变爻的爻辞解卦，而以上爻的卦辞为主作综合考虑
            let lowerPosition = changingYaoPositions.min() ?? 1
            let upperPosition = changingYaoPositions.max() ?? 2
            let upperYaoContent = yaoContents[upperPosition] ?? "[爻辞加载中...]"
            let lowerYaoContent = yaoContents[lowerPosition] ?? "[爻辞加载中...]"
            return (
                strategy: "两个变爻 - 用两个变爻爻辞解卦，以上爻为主",
                content: "用本卦第\(lowerPosition)爻和第\(upperPosition)爻的爻辞解卦，以第\(upperPosition)爻为主。\n\n【解卦要点】\n以上爻（第\(upperPosition)爻）的爻辞为主要依据，下爻（第\(lowerPosition)爻）的爻辞为辅助依据。\n\n【主要爻辞】\n\(upperYaoContent)\n\n【辅助爻辞】\n\(lowerYaoContent)"
            )
            
        case 3:
            // 4.卦中有三个变爻，解卦时用本卦的卦辞并结合变卦的卦辞作综合考虑，但以本卦卦辞为主，变卦卦辞为辅
            let changedYao = calculateChangedYao(originalYao: originalYao, changingPositions: changingYaoPositions)
            let changedGuaName = generateGuaName(from: changedYao)
            let changedGuaContent = await getChangedGuaContent(changedGuaName)
            
            return (
                strategy: "三个变爻 - 本卦卦辞为主，变卦卦辞为辅",
                content: "用本卦卦辞为主，变卦卦辞为辅进行综合考虑。\n\n【解卦要点】\n以本卦卦辞为主要依据，变卦卦辞为辅助参考。\n\n【变卦：\(changedGuaName)】\n\(changedGuaContent)"
            )
            
        case 4:
            // 5.卦中有四个变爻，用变卦的两个不变爻的爻辞解卦，而以下爻爻辞为主作综合考虑
            let unchangedPositions = getUnchangedYaoPositions(changingYaoPositions: changingYaoPositions)
            let lowerUnchanged = unchangedPositions.min() ?? 1
            let upperUnchanged = unchangedPositions.max() ?? 2
            
            let changedYao = calculateChangedYao(originalYao: originalYao, changingPositions: changingYaoPositions)
            let changedGuaName = generateGuaName(from: changedYao)
            let changedYaoContents = await getChangedGuaYaoContents(changedGuaName)
            
            let lowerYaoContent = changedYaoContents[lowerUnchanged] ?? "[变卦第\(lowerUnchanged)爻爻辞加载中...]"
            let upperYaoContent = changedYaoContents[upperUnchanged] ?? "[变卦第\(upperUnchanged)爻爻辞加载中...]"
            
            return (
                strategy: "四个变爻 - 用变卦不变爻爻辞解卦，以下爻为主",
                content: "用变卦的两个不变爻（第\(lowerUnchanged)爻和第\(upperUnchanged)爻）的爻辞解卦，以第\(lowerUnchanged)爻为主。\n\n【变卦：\(changedGuaName)】\n\n【解卦要点】\n以变卦下爻（第\(lowerUnchanged)爻）的爻辞为主要依据，上爻（第\(upperUnchanged)爻）的爻辞为辅助依据。\n\n【主要爻辞】\n\(lowerYaoContent)\n\n【辅助爻辞】\n\(upperYaoContent)"
            )
            
        case 5:
            // 6.卦中有五个变爻，用变卦的不变爻的爻辞解卦
            let unchangedPosition = getUnchangedYaoPositions(changingYaoPositions: changingYaoPositions).first ?? 1
            
            let changedYao = calculateChangedYao(originalYao: originalYao, changingPositions: changingYaoPositions)
            let changedGuaName = generateGuaName(from: changedYao)
            let changedYaoContents = await getChangedGuaYaoContents(changedGuaName)
            
            let unchangedYaoContent = changedYaoContents[unchangedPosition] ?? "[变卦第\(unchangedPosition)爻爻辞加载中...]"
            
            return (
                strategy: "五个变爻 - 用变卦不变爻爻辞解卦",
                content: "用变卦的不变爻（第\(unchangedPosition)爻）的爻辞解卦。\n\n【变卦：\(changedGuaName)】\n\n【解卦要点】\n以变卦不变爻的爻辞为唯一依据。\n\n【爻辞内容】\n\(unchangedYaoContent)"
            )
            
        case 6:
            // 7.卦中六爻都是变爻，如果是乾坤两卦就用"用九"、"用六"解卦，其他则用变卦的卦辞解卦
            let isQianKun = guaName.contains("乾") || guaName.contains("坤")
            if isQianKun {
                let useNine = guaName.contains("乾") ? "用九" : "用六"
                return (
                    strategy: "六爻皆变 - 乾坤卦用\"\(useNine)\"解卦",
                    content: "六爻皆变，本卦为\(guaName.contains("乾") ? "乾" : "坤")卦，用\"\(useNine)\"解卦。\n\n【解卦要点】\n以\"\(useNine)\"的内容为解卦依据。\n\n【\(useNine)内容】\n[待添加\(useNine)具体内容]"
                )
            } else {
                let changedYao = calculateChangedYao(originalYao: originalYao, changingPositions: changingYaoPositions)
                let changedGuaName = generateGuaName(from: changedYao)
                let changedGuaContent = await getChangedGuaContent(changedGuaName)
                
                return (
                    strategy: "六爻皆变 - 用变卦卦辞解卦",
                    content: "六爻皆变，用变卦的卦辞解卦。\n\n【变卦：\(changedGuaName)】\n\n【解卦要点】\n以变卦卦辞为解卦依据。\n\n【变卦卦辞】\n\(changedGuaContent)"
                )
            }
            
        default:
            return (
                strategy: "未知情况",
                content: "变爻数量异常，请检查卦象。"
            )
        }
    }
    
    // 获取未变爻的位置（用于4个和5个变爻的情况）
    private static func getUnchangedYaoPositions(changingYaoPositions: [Int]) -> [Int] {
        let allPositions = Set(1...6)
        let changingPositions = Set(changingYaoPositions)
        return Array(allPositions.subtracting(changingPositions)).sorted()
    }
    
    // 异步获取变卦的卦辞内容
    private static func getChangedGuaContent(_ guaName: String) async -> String {
        let url = getGuaURL(fullGua: guaName)
        return await fetchGuaContent(from: url)
    }

    // 异步获取变卦的爻辞内容
    private static func getChangedGuaYaoContents(_ guaName: String) async -> [Int: String] {
        let url = getGuaURL(fullGua: guaName)
        let html = await fetchHTML(from: url)
        return HTMLContentExtractor.extractAllYao(from: html)
    }

    // 异步获取HTML内容
    private static func fetchHTML(from url: URL) async -> String {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("获取变卦HTML内容失败: \(error)")
            return ""
        }
    }

    // 异步获取并解析卦辞内容
    private static func fetchGuaContent(from url: URL) async -> String {
        let html = await fetchHTML(from: url)
        return HTMLContentExtractor.extractMainContent(from: html)
    }

    // 从卦名生成URL
    private static func getGuaURL(fullGua: String) -> URL {
        // 提取数字前缀
        let components = fullGua.components(separatedBy: ". ")
        guard components.count >= 2,
              let guaNumber = Int(components[0]) else {
            return URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/4103.html")!
        }
        
        // 计算URL ID (基础4103加上卦的序号减1)
        let urlId = 4103 + guaNumber - 1
        return URL(string: "https://www.zhouyi.cc/zhouyi/yijing64/\(urlId).html")!
    }
}

// 从GuaResultView复制的辅助函数（避免循环依赖）
func yaoToGuaCode(_ yao: [Int]) -> [Int] {
    return yao.map { $0 == 6 || $0 == 8 ? 0 : 1 }
}

func yaoToGuaName(_ yao: [Int]) -> String {
    let code = yaoToGuaCode(yao)
    let guaNames = ["坤", "艮", "坎", "巽", "震", "离", "兑", "乾"]
    let idx = code[0]*4 + code[1]*2 + code[2]
    return guaNames[idx]
}

func getFullGuaName(inner: String, outer: String) -> String {
    let guaFullMap: [String: [String]] = [
        "坤": ["2. 坤为地", "15. 地山谦", "7. 地水师", "46. 地风升", "24. 地雷复", "36. 地火明夷", "19. 地泽临", "11. 地天泰"],
        "艮": ["23. 山地剥", "52. 艮为山", "4. 山水蒙", "18. 山风蛊", "27. 山雷颐", "22. 山火贲", "41. 山泽损", "26. 山天大畜"],
        "坎": ["8. 水地比", "39. 水山蹇", "29. 坎为水", "48. 水风井", "3. 水雷屯", "63. 水火既济", "60. 水泽节", "5. 水天需"],
        "巽": ["20. 风地观", "53. 风山渐", "59. 风水涣", "57. 巽为风", "42. 风雷益", "37. 风火家人", "61. 风泽中孚", "9. 风天小畜"],
        "震": ["16. 雷地豫", "62. 雷山小过", "40. 雷水解", "32. 雷风恒", "51. 震为雷", "55. 雷火丰", "54. 雷泽归妹", "34. 雷天大壮"],
        "离": ["35. 火地晋", "56. 火山旅", "64. 火水未济", "50. 火风鼎", "21. 火雷噬嗑", "30. 离为火", "38. 火泽睽", "14. 火天大有"],
        "兑": ["45. 泽地萃", "31. 泽山咸", "47. 泽水困", "28. 泽风大过", "17. 泽雷随", "49. 泽火革", "58. 兑为泽", "43. 泽天夬"],
        "乾": ["12. 天地否", "33. 天山遁", "6. 天水讼", "44. 天风姤", "25. 天雷无妄", "13. 天火同人", "10. 天泽履", "1. 乾为天"]
    ]
    let innerIdx = ["坤", "艮", "坎", "巽", "震", "离", "兑", "乾"].firstIndex(of: inner) ?? 0
    let arr = guaFullMap[outer] ?? []
    return arr.count > innerIdx ? arr[innerIdx] : "未知卦"
}
