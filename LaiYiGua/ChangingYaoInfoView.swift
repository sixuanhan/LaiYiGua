import SwiftUI

struct ChangingYaoInfoView: View {
    let changingYaoPositions: [Int]
    
    private var changingYaoCount: Int {
        return changingYaoPositions.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("变爻信息")
                .font(.title2)
                .fontWeight(.bold)
            
            if changingYaoCount > 0 {
                Text("变爻数量：\(changingYaoCount)个")
                    .font(.body)
                Text("变爻位置：第\(changingYaoPositions.map(String.init).joined(separator: "、"))爻")
                    .font(.body)
                Text("解读提示：变爻表示变化的关键点，需要特别关注")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else {
                Text("无变爻")
                    .font(.body)
                    .foregroundColor(.gray)
                Text("解读提示：静卦，重点关注卦辞和整体寓意")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    VStack {
        ChangingYaoInfoView(changingYaoPositions: [2, 3])
        ChangingYaoInfoView(changingYaoPositions: [])
    }
    .padding()
}
