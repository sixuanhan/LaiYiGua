import Foundation

class InterpretationStrategy {
    static func getStrategy(
        changingYaoPositions: [Int],
        yaoContents: [Int: String],
        content: String,
        guaName: String
    ) -> (strategy: String, content: String) {
        
        let changingYaoCount = changingYaoPositions.count
        
        switch changingYaoCount {
        case 0:
            // 1.六爻不变，依据本卦卦辞来解卦
            return (
                strategy: "六爻不变 - 用本卦卦辞解卦",
                content: "依据本卦卦辞来解卦。\n\n【解卦要点】\n本卦卦辞为主要依据，分析所问之事的吉凶。\n\n【卦辞内容】\n\(content.isEmpty ? "[卦辞加载中...]" : content)"
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
            return (
                strategy: "三个变爻 - 本卦卦辞为主，变卦卦辞为辅",
                content: "用本卦卦辞为主，变卦卦辞为辅进行综合考虑。\n\n【解卦要点】\n以本卦卦辞为主要依据，变卦卦辞为辅助参考。\n\n【本卦卦辞】\n[待添加本卦卦辞内容]\n\n【变卦卦辞】\n[待添加变卦卦辞内容]"
            )
            
        case 4:
            // 5.卦中有四个变爻，用变卦的两个不变爻的爻辞解卦，而以下爻爻辞为主作综合考虑
            let unchangedPositions = getUnchangedYaoPositions(changingYaoPositions: changingYaoPositions)
            let lowerUnchanged = unchangedPositions.min() ?? 1
            let upperUnchanged = unchangedPositions.max() ?? 2
            return (
                strategy: "四个变爻 - 用变卦不变爻爻辞解卦，以下爻为主",
                content: "用变卦的两个不变爻（第\(lowerUnchanged)爻和第\(upperUnchanged)爻）的爻辞解卦，以第\(lowerUnchanged)爻为主。\n\n【解卦要点】\n以变卦下爻（第\(lowerUnchanged)爻）的爻辞为主要依据，上爻（第\(upperUnchanged)爻）的爻辞为辅助依据。\n\n【主要爻辞】\n[待添加变卦第\(lowerUnchanged)爻爻辞内容]\n\n【辅助爻辞】\n[待添加变卦第\(upperUnchanged)爻爻辞内容]"
            )
            
        case 5:
            // 6.卦中有五个变爻，用变卦的不变爻的爻辞解卦
            let unchangedPosition = getUnchangedYaoPositions(changingYaoPositions: changingYaoPositions).first ?? 1
            return (
                strategy: "五个变爻 - 用变卦不变爻爻辞解卦",
                content: "用变卦的不变爻（第\(unchangedPosition)爻）的爻辞解卦。\n\n【解卦要点】\n以变卦不变爻的爻辞为唯一依据。\n\n【爻辞内容】\n[待添加变卦第\(unchangedPosition)爻爻辞内容]"
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
                return (
                    strategy: "六爻皆变 - 用变卦卦辞解卦",
                    content: "六爻皆变，用变卦的卦辞解卦。\n\n【解卦要点】\n以变卦卦辞为解卦依据。\n\n【变卦卦辞】\n[待添加变卦卦辞内容]"
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
}
