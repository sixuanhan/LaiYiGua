import SwiftUI

struct SticksLayoutView: View {
    @State private var splitIndex: Int? = nil
    @State private var isSplit: Bool = false
    @State private var movedStick: Bool = false
    @State private var grouped: Bool = false
    let totalSticks = 49
    // 横屏专用
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    // 新增全局变量
    @State private var leftCount: Int = 0
    @State private var leftRemainder: Int = 0
    @State private var rightCount: Int = 0
    @State private var rightRemainder: Int = 0
    @State private var removedSticks: Int = 0
    @State private var centerSticks: Int = 0
    @State private var stepCount: Int = 1 // 新增：记录当前轮次
    @State private var sticksLeft: Int = 49 // 新增：当前剩余木棍数

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 居中横在页面上方的木棍
                StickView()
                    .frame(width: geometry.size.width * 0.6, height: 18)
                    .rotationEffect(.degrees(90))
                    .position(x: geometry.size.width / 2, y: 40)
                // 左下角斜着的木棍（第二次点击后出现）
                if movedStick {
                    StickView()
                        .frame(width: 30, height: 120)
                        .rotationEffect(.degrees(-30))
                        .position(x: geometry.size.width * 0.12, y: geometry.size.height - 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.6), value: movedStick)
                }
                // 分组显示
                if let split = splitIndex, isSplit, grouped {
                    // 左堆分组
                    let leftGroups = leftRemainder == 4 ? leftCount / 4 - 1 : leftCount / 4
                    // 右堆分组
                    let rightGroups = rightRemainder == 4 ? rightCount / 4 - 1 : rightCount / 4
                    HStack(alignment: .bottom, spacing: geometry.size.width * 0.25) { // 用屏幕宽度控制左右堆间距
                        // 左堆
                        VStack(spacing: -190) { // 负值让堆叠更紧凑
                            ForEach(0..<leftGroups, id: \.self) { i in
                                HStack(spacing: 0.5) {
                                    ForEach(0..<4, id: \.self) { _ in
                                        Rectangle()
                                            .fill(Color.brown)
                                            .frame(width: 10, height: 150)
                                            .cornerRadius(3)
                                            .shadow(radius: 2)
                                            .rotationEffect(.degrees(-60))
                                    }
                                }
                            }
                            if leftRemainder > 0 {
                                HStack(spacing: 0.5) {
                                    ForEach(0..<leftRemainder, id: \.self) { _ in
                                        Rectangle()
                                            .fill(Color.red)
                                            .frame(width: 10, height: 150)
                                            .cornerRadius(3)
                                            .shadow(radius: 2)
                                            .rotationEffect(.degrees(-60))
                                    }
                                }
                                .opacity(0.8)
                            }
                        }
                        // 右堆
                        VStack(spacing: -190) { // 负值让堆叠更紧凑
                            ForEach(0..<rightGroups, id: \.self) { i in
                                HStack(spacing: 0.5) {
                                    ForEach(0..<4, id: \.self) { _ in
                                        Rectangle()
                                            .fill(Color.brown)
                                            .frame(width: 10, height: 150)
                                            .cornerRadius(3)
                                            .shadow(radius: 2)
                                            .rotationEffect(.degrees(-60))
                                    }
                                }
                            }
                            if rightRemainder > 0 {
                                HStack(spacing: 0.5) {
                                    ForEach(0..<rightRemainder, id: \.self) { _ in
                                        Rectangle()
                                            .fill(Color.blue)
                                            .frame(width: 10, height: 150)
                                            .cornerRadius(3)
                                            .shadow(radius: 2)
                                            .rotationEffect(.degrees(-60))
                                    }
                                }
                                .opacity(0.8)
                            }
                        }
                    }
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.7)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                } else if let split = splitIndex, isSplit, grouped, movedStick {
                    VStack {
                        Spacer()
                        HStack(spacing: 2) {
                            ForEach(0..<centerSticks, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.brown)
                                    .frame(width: 10, height: 150)
                                    .cornerRadius(3)
                                    .shadow(radius: 2)
                            }
                            // 加上左下角那根
                            Rectangle()
                                .fill(Color.brown)
                                .frame(width: 10, height: 150)
                                .cornerRadius(3)
                                .shadow(radius: 2)
                        }
                        Spacer()
                    }
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.7)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                } else if let split = splitIndex, isSplit {
                    HStack(alignment: .center, spacing: 6) {
                        HStack(spacing: 6) {
                            ForEach(0..<split, id: \.self) { _ in
                                StickView()
                                    .frame(width: 4, height: geometry.size.height * 0.3)
                                    .transition(.scale)
                                    .animation(.easeInOut(duration: 0.6), value: splitIndex)
                            }
                        }
                        Spacer(minLength: 40) // 增加两堆之间的间隔
                        HStack(spacing: 6) {
                            ForEach(0..<(totalSticks - split - (movedStick ? 1 : 0)), id: \.self) { i in
                                StickView()
                                    .frame(width: 4, height: geometry.size.height * 0.3)
                                    .transition(.scale)
                                    .animation(.easeInOut(duration: 0.6), value: movedStick)
                            }
                        }
                    }
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.5)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                } else {
                    HStack(alignment: .center, spacing: 6) {
                        ForEach(0..<totalSticks, id: \.self) { _ in
                            StickView()
                                .frame(width: 4, height: geometry.size.height * 0.3)
                        }
                    }
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.5)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if !isSplit {
                    let minSplit = 1
                    let maxSplit = sticksLeft - 1
                    withAnimation(.easeInOut(duration: 0.6)) {
                        splitIndex = Int.random(in: minSplit...maxSplit)
                        isSplit = true
                        leftCount = splitIndex ?? 0
                    }
                    print("第\(stepCount)轮：分堆 splitIndex=\(splitIndex!), isSplit=\(isSplit), movedStick=\(movedStick), grouped=\(grouped), sticksLeft=\(sticksLeft)")
                } else if isSplit && !movedStick {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        movedStick = true
                        rightCount = sticksLeft - leftCount - 1
                    }
                    print("第\(stepCount)轮：移棍 movedStick set to true, splitIndex=\(splitIndex!), isSplit=\(isSplit), grouped=\(grouped), sticksLeft=\(sticksLeft)")
                } else if isSplit && movedStick && !grouped {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        grouped = true
                        leftRemainder = leftCount % 4 == 0 ? 4 : leftCount % 4
                        rightRemainder = rightCount % 4 == 0 ? 4 : rightCount % 4
                        removedSticks = leftRemainder + rightRemainder
                        centerSticks = sticksLeft - removedSticks - 1
                        sticksLeft = centerSticks + 1 // 在分余数阶段更新 sticksLeft
                    }
                    print("第\(stepCount)轮：分余数 leftRemainder=\(leftRemainder), rightRemainder=\(rightRemainder), sticksLeft=\(sticksLeft)")
                } else if isSplit && movedStick && grouped {
                    print("第\(stepCount)轮：移除余数 红色余数数量: \(leftRemainder), 蓝色余数数量: \(rightRemainder), 当前平摊数量: \(centerSticks + 1), sticksLeft=\(sticksLeft)")
                    withAnimation(.easeInOut(duration: 0.6)) {
                        splitIndex = nil
                        isSplit = false
                        movedStick = false
                        grouped = false
                        leftCount = 0
                        rightCount = 0
                        leftRemainder = 0
                        rightRemainder = 0
                        removedSticks = 0
                        centerSticks = 0
                        if stepCount < 3 {
                            stepCount += 1
                        } else {
                            print("三轮结束，可在此处处理最终结果")
                            stepCount = 1 // 重置，允许重新开始
                            sticksLeft = 49 // 重置为初始值
                        }
                    }
                    print("User tapped again: reset, splitIndex=\(splitIndex?.description ?? "nil"), isSplit=\(isSplit), movedStick=\(movedStick), grouped=\(grouped), stepCount=\(stepCount)")
                }
            }
        }
    }
}

#Preview {
    SticksLayoutView()
}
