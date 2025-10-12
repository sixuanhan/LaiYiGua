import SwiftUI

// 八卦组合到六十四卦的先天序号和卦名
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

// 卦名与Unicode符号映射
let guaUnicode: [String: String] = [
    "坤": "\u{2637}", "艮": "\u{2636}", "坎": "\u{2635}", "巽": "\u{2634}", "震": "\u{2633}", "离": "\u{2632}", "兑": "\u{2631}", "乾": "\u{2630}"
]

// 六十四卦名到链接的映射
/*
控制台指令：
// 兼容多种结构抓取链接
const links = Array.from(document.querySelectorAll("a"))
  .filter(a => a.href.includes("/zhouyi/yijing64/") && a.href.endsWith(".html"));

if (links.length === 0) {
  console.log("⚠️ 没找到卦的链接。请确认当前页面是否是 https://www.zhouyi.cc/zhouyi/yijing64/");
} else {
  const guaMap = links.map(a => {
    const name = a.innerText.trim().replace(/\s+/g, ""); // 去掉空格
    const href = a.href.trim();
    return `    "${name}": "${href}"`;
  });

  const swiftDict = `let guaLinks: [String: String] = [\n${guaMap.join(",\n")}\n]`;
  console.log(swiftDict);
}
*/
let guaLinks: [String: String] = [
    "乾卦": "https://www.zhouyi.cc/zhouyi/yijing64/4103.html",
    "乾为天": "https://www.zhouyi.cc/zhouyi/yijing64/4103.html",
    "夬卦": "https://www.zhouyi.cc/zhouyi/yijing64/4183.html",
    "泽天夬": "https://www.zhouyi.cc/zhouyi/yijing64/4183.html",
    "大有卦": "https://www.zhouyi.cc/zhouyi/yijing64/4141.html",
    "火天大有": "https://www.zhouyi.cc/zhouyi/yijing64/4141.html",
    "大壮卦": "https://www.zhouyi.cc/zhouyi/yijing64/4173.html",
    "雷天大壮": "https://www.zhouyi.cc/zhouyi/yijing64/4173.html",
    "小畜卦": "https://www.zhouyi.cc/zhouyi/yijing64/4112.html",
    "风天小畜": "https://www.zhouyi.cc/zhouyi/yijing64/4112.html",
    "需卦": "https://www.zhouyi.cc/zhouyi/yijing64/4108.html",
    "水天需": "https://www.zhouyi.cc/zhouyi/yijing64/4108.html",
    "大畜卦": "https://www.zhouyi.cc/zhouyi/yijing64/4159.html",
    "山天大畜": "https://www.zhouyi.cc/zhouyi/yijing64/4159.html",
    "泰卦": "https://www.zhouyi.cc/zhouyi/yijing64/4126.html",
    "地天泰": "https://www.zhouyi.cc/zhouyi/yijing64/4126.html",
    "履卦": "https://www.zhouyi.cc/zhouyi/yijing64/4113.html",
    "天泽履": "https://www.zhouyi.cc/zhouyi/yijing64/4113.html",
    "兑卦": "https://www.zhouyi.cc/zhouyi/yijing64/4200.html",
    "兑为泽": "https://www.zhouyi.cc/zhouyi/yijing64/4200.html",
    "睽卦": "https://www.zhouyi.cc/zhouyi/yijing64/4177.html",
    "火泽睽": "https://www.zhouyi.cc/zhouyi/yijing64/4177.html",
    "归妹卦": "https://www.zhouyi.cc/zhouyi/yijing64/4195.html",
    "雷泽归妹": "https://www.zhouyi.cc/zhouyi/yijing64/4195.html",
    "中孚卦": "https://www.zhouyi.cc/zhouyi/yijing64/4255.html",
    "风泽中孚": "https://www.zhouyi.cc/zhouyi/yijing64/4255.html",
    "节卦": "https://www.zhouyi.cc/zhouyi/yijing64/4244.html",
    "水泽节": "https://www.zhouyi.cc/zhouyi/yijing64/4244.html",
    "损卦": "https://www.zhouyi.cc/zhouyi/yijing64/4181.html",
    "山泽损": "https://www.zhouyi.cc/zhouyi/yijing64/4181.html",
    "临卦": "https://www.zhouyi.cc/zhouyi/yijing64/4146.html",
    "地泽临": "https://www.zhouyi.cc/zhouyi/yijing64/4146.html",
    "同人卦": "https://www.zhouyi.cc/zhouyi/yijing64/4140.html",
    "天火同人": "https://www.zhouyi.cc/zhouyi/yijing64/4140.html",
    "革卦": "https://www.zhouyi.cc/zhouyi/yijing64/4189.html",
    "泽火革": "https://www.zhouyi.cc/zhouyi/yijing64/4189.html",
    "离卦": "https://www.zhouyi.cc/zhouyi/yijing64/4169.html",
    "离为火": "https://www.zhouyi.cc/zhouyi/yijing64/4169.html",
    "丰卦": "https://www.zhouyi.cc/zhouyi/yijing64/4196.html",
    "雷火丰": "https://www.zhouyi.cc/zhouyi/yijing64/4196.html",
    "家人卦": "https://www.zhouyi.cc/zhouyi/yijing64/4176.html",
    "风火家人": "https://www.zhouyi.cc/zhouyi/yijing64/4176.html",
    "既济卦": "https://www.zhouyi.cc/zhouyi/yijing64/4257.html",
    "水火既济": "https://www.zhouyi.cc/zhouyi/yijing64/4257.html",
    "贲卦": "https://www.zhouyi.cc/zhouyi/yijing64/4149.html",
    "山火贲": "https://www.zhouyi.cc/zhouyi/yijing64/4149.html",
    "明夷卦": "https://www.zhouyi.cc/zhouyi/yijing64/4175.html",
    "地火明夷": "https://www.zhouyi.cc/zhouyi/yijing64/4175.html",
    "无妄卦": "https://www.zhouyi.cc/zhouyi/yijing64/4153.html",
    "天雷无妄": "https://www.zhouyi.cc/zhouyi/yijing64/4153.html",
    "随卦": "https://www.zhouyi.cc/zhouyi/yijing64/4144.html",
    "泽雷随": "https://www.zhouyi.cc/zhouyi/yijing64/4144.html",
    "噬嗑卦": "https://www.zhouyi.cc/zhouyi/yijing64/4148.html",
    "火雷噬嗑": "https://www.zhouyi.cc/zhouyi/yijing64/4148.html",
    "震卦": "https://www.zhouyi.cc/zhouyi/yijing64/4192.html",
    "震为雷": "https://www.zhouyi.cc/zhouyi/yijing64/4192.html",
    "益卦": "https://www.zhouyi.cc/zhouyi/yijing64/4182.html",
    "风雷益": "https://www.zhouyi.cc/zhouyi/yijing64/4182.html",
    "屯卦": "https://www.zhouyi.cc/zhouyi/yijing64/4106.html",
    "水雷屯": "https://www.zhouyi.cc/zhouyi/yijing64/4106.html",
    "颐卦": "https://www.zhouyi.cc/zhouyi/yijing64/4164.html",
    "山雷颐": "https://www.zhouyi.cc/zhouyi/yijing64/4164.html",
    "复卦": "https://www.zhouyi.cc/zhouyi/yijing64/4152.html",
    "地雷复": "https://www.zhouyi.cc/zhouyi/yijing64/4152.html",
    "姤卦": "https://www.zhouyi.cc/zhouyi/yijing64/4184.html",
    "天风姤": "https://www.zhouyi.cc/zhouyi/yijing64/4184.html",
    "大过卦": "https://www.zhouyi.cc/zhouyi/yijing64/4167.html",
    "泽风大过": "https://www.zhouyi.cc/zhouyi/yijing64/4167.html",
    "鼎卦": "https://www.zhouyi.cc/zhouyi/yijing64/4190.html",
    "火风鼎": "https://www.zhouyi.cc/zhouyi/yijing64/4190.html",
    "恒卦": "https://www.zhouyi.cc/zhouyi/yijing64/4171.html",
    "雷风恒": "https://www.zhouyi.cc/zhouyi/yijing64/4171.html",
    "巽卦": "https://www.zhouyi.cc/zhouyi/yijing64/4198.html",
    "巽为风": "https://www.zhouyi.cc/zhouyi/yijing64/4198.html",
    "井卦": "https://www.zhouyi.cc/zhouyi/yijing64/4188.html",
    "水风井": "https://www.zhouyi.cc/zhouyi/yijing64/4188.html",
    "蛊卦": "https://www.zhouyi.cc/zhouyi/yijing64/4145.html",
    "山风蛊": "https://www.zhouyi.cc/zhouyi/yijing64/4145.html",
    "升卦": "https://www.zhouyi.cc/zhouyi/yijing64/4186.html",
    "地风升": "https://www.zhouyi.cc/zhouyi/yijing64/4186.html",
    "讼卦": "https://www.zhouyi.cc/zhouyi/yijing64/4109.html",
    "天水讼": "https://www.zhouyi.cc/zhouyi/yijing64/4109.html",
    "困卦": "https://www.zhouyi.cc/zhouyi/yijing64/4187.html",
    "泽水困": "https://www.zhouyi.cc/zhouyi/yijing64/4187.html",
    "未济卦": "https://www.zhouyi.cc/zhouyi/yijing64/4263.html",
    "火水未济": "https://www.zhouyi.cc/zhouyi/yijing64/4263.html",
    "解卦": "https://www.zhouyi.cc/zhouyi/yijing64/4180.html",
    "雷水解": "https://www.zhouyi.cc/zhouyi/yijing64/4180.html",
    "涣卦": "https://www.zhouyi.cc/zhouyi/yijing64/4212.html",
    "风水涣": "https://www.zhouyi.cc/zhouyi/yijing64/4212.html",
    "坎卦": "https://www.zhouyi.cc/zhouyi/yijing64/4168.html",
    "坎为水": "https://www.zhouyi.cc/zhouyi/yijing64/4168.html",
    "蒙卦": "https://www.zhouyi.cc/zhouyi/yijing64/4107.html",
    "山水蒙": "https://www.zhouyi.cc/zhouyi/yijing64/4107.html",
    "师卦": "https://www.zhouyi.cc/zhouyi/yijing64/4110.html",
    "地水师": "https://www.zhouyi.cc/zhouyi/yijing64/4110.html",
    "遁卦": "https://www.zhouyi.cc/zhouyi/yijing64/4172.html",
    "天山遁": "https://www.zhouyi.cc/zhouyi/yijing64/4172.html",
    "咸卦": "https://www.zhouyi.cc/zhouyi/yijing64/4170.html",
    "泽山咸": "https://www.zhouyi.cc/zhouyi/yijing64/4170.html",
    "旅卦": "https://www.zhouyi.cc/zhouyi/yijing64/4197.html",
    "火山旅": "https://www.zhouyi.cc/zhouyi/yijing64/4197.html",
    "小过卦": "https://www.zhouyi.cc/zhouyi/yijing64/4256.html",
    "雷山小过": "https://www.zhouyi.cc/zhouyi/yijing64/4256.html",
    "渐卦": "https://www.zhouyi.cc/zhouyi/yijing64/4194.html",
    "风山渐": "https://www.zhouyi.cc/zhouyi/yijing64/4194.html",
    "蹇卦": "https://www.zhouyi.cc/zhouyi/yijing64/4179.html",
    "水山蹇": "https://www.zhouyi.cc/zhouyi/yijing64/4179.html",
    "艮卦": "https://www.zhouyi.cc/zhouyi/yijing64/4193.html",
    "艮为山": "https://www.zhouyi.cc/zhouyi/yijing64/4193.html",
    "谦卦": "https://www.zhouyi.cc/zhouyi/yijing64/4142.html",
    "地山谦": "https://www.zhouyi.cc/zhouyi/yijing64/4142.html",
    "否卦": "https://www.zhouyi.cc/zhouyi/yijing64/4127.html",
    "天地否": "https://www.zhouyi.cc/zhouyi/yijing64/4127.html",
    "萃卦": "https://www.zhouyi.cc/zhouyi/yijing64/4185.html",
    "泽地萃": "https://www.zhouyi.cc/zhouyi/yijing64/4185.html",
    "晋卦": "https://www.zhouyi.cc/zhouyi/yijing64/4174.html",
    "火地晋": "https://www.zhouyi.cc/zhouyi/yijing64/4174.html",
    "豫卦": "https://www.zhouyi.cc/zhouyi/yijing64/4143.html",
    "雷地豫": "https://www.zhouyi.cc/zhouyi/yijing64/4143.html",
    "观卦": "https://www.zhouyi.cc/zhouyi/yijing64/4147.html",
    "风地观": "https://www.zhouyi.cc/zhouyi/yijing64/4147.html",
    "比卦": "https://www.zhouyi.cc/zhouyi/yijing64/4111.html",
    "水地比": "https://www.zhouyi.cc/zhouyi/yijing64/4111.html",
    "剥卦": "https://www.zhouyi.cc/zhouyi/yijing64/4150.html",
    "山地剥": "https://www.zhouyi.cc/zhouyi/yijing64/4150.html",
    "坤卦": "https://www.zhouyi.cc/zhouyi/yijing64/4105.html",
    "坤为地": "https://www.zhouyi.cc/zhouyi/yijing64/4105.html",
]

// 获取卦的详情链接URL
func getGuaURL(fullGua: String) -> URL {
    let guaName = fullGua.components(separatedBy: ".").last?.trimmingCharacters(in: .whitespaces) ?? fullGua
    let url1 = guaLinks[guaName]
    let url2 = guaLinks[fullGua]
    let urlString = url1 ?? url2 ?? "https://www.zhouyi.cc"
    return URL(string: urlString) ?? URL(string: "https://www.zhouyi.cc")!
}

struct GuaResultView: View {
    let yao: [Int]
    
    // 计算变爻信息
    private var changingYaoInfo: (count: Int, positions: [Int]) {
        var positions: [Int] = []
        for (index, value) in yao.enumerated() {
            if value == 6 || value == 9 {
                positions.append(index + 1) // 从1开始计数
            }
        }
        return (count: positions.count, positions: positions)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            let inner = Array(yao[0...2])
            let outer = Array(yao[3...5])
            let innerName = yaoToGuaName(inner)
            let outerName = yaoToGuaName(outer)
            let fullGua = getFullGuaName(inner: innerName, outer: outerName)
            let changingInfo = changingYaoInfo

            Text("\(fullGua)")
                .font(.title)
                .bold()

            VStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { i in
                    let v = yao[i]
                    HStack(spacing: 2) {
                        if v == 6 || v == 8 {
                            // 阴爻
                            Rectangle().frame(width: 60, height: 12).foregroundColor(.gray)
                            Rectangle().frame(width: 20, height: 12).foregroundColor(.clear)
                            Rectangle().frame(width: 60, height: 12).foregroundColor(.gray)
                        } else {
                            // 阳爻
                            Rectangle().frame(width: 145, height: 12).foregroundColor(.black)
                        }
                    }
                }
            }
            .padding(.vertical)

            Text("内卦：\(innerName)  外卦：\(outerName)")
                .font(.title2)
                .padding(.top)
            
            // 显示变爻信息
            if changingInfo.count > 0 {
                Text("变爻：\(changingInfo.count)个 (第\(changingInfo.positions.map(String.init).joined(separator: "、"))爻)")
                    .font(.body)
                    .foregroundColor(.orange)
                    .padding(.top, 4)
            } else {
                Text("无变爻")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            
            HStack(spacing: 20) {
                NavigationLink(destination: GuaDetailView(
                    guaName: fullGua,
                    guaURL: getGuaURL(fullGua: fullGua),
                    changingYaoPositions: changingInfo.positions,
                    originalYao: yao
                )) {
                    Text("解卦")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    let debugFullGua = fullGua
                    // 取卦名（去掉序号和空格）
                    let guaName = fullGua.components(separatedBy: ".").last?.trimmingCharacters(in: .whitespaces) ?? fullGua
                    let url1 = guaLinks[guaName]
                    let url2 = guaLinks[fullGua]
                    print("[DEBUG] fullGua=\(debugFullGua), guaName=\(guaName), url1=\(url1 ?? "nil"), url2=\(url2 ?? "nil")")
                    if let url = url1 ?? url2 {
                        if let link = URL(string: url) {
                            print("[DEBUG] Opening URL: \(link)")
                            #if os(iOS)
                            UIApplication.shared.open(link)
                            #elseif os(macOS)
                            NSWorkspace.shared.open(link)
                            #endif
                        } else {
                            print("[DEBUG] URL string invalid: \(url)")
                        }
                    } else {
                        print("[DEBUG] No URL found for guaName: \(guaName) or fullGua: \(fullGua)")
                    }
                }) {
                    Text("查看卦象详情")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

#if DEBUG
struct GuaResultView_Previews: PreviewProvider {
    static var previews: some View {
        // 示例卦：[7,6,9,8,7,7]，内卦离，外卦巽，第2和第3爻为变爻
        GuaResultView(yao: [7,6,9,8,7,7])
    }
}
#endif
