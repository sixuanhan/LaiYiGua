import SwiftUI

struct SticksLayoutView: View {
    let question: String
    @EnvironmentObject private var navigationManager: NavigationManager
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
    @State private var yaoList: [Int] = [] // 新增：记录每轮生成的爻
    @State private var navigateToResult: Bool = false // 新增：控制跳转到卦展示页面
    // 拖拽相关状态
    @State private var isDragging: Bool = false
    @State private var dragPosition: CGPoint = .zero
    @State private var splitLinePosition: CGFloat = 0.5 // 分割线位置（0.0-1.0）

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 用户提示
                if !isSplit && stepCount == 1 {
                    VStack {
                        Text("请按住并拖动来分割木棍堆")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        Spacer()
                    }
                    .padding(.top, 60)
                } else if isSplit && !movedStick {
                    VStack {
                        Text("点击移出一根木棍")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        Spacer()
                    }
                    .padding(.top, 60)
                } else if movedStick && !grouped {
                    VStack {
                        Text("点击分组并计算余数")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        Spacer()
                    }
                    .padding(.top, 60)
                } else if grouped && stepCount < 3 {
                    VStack {
                        Text("点击继续下一轮")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        Spacer()
                    }
                    .padding(.top, 60)
                } else if grouped && stepCount == 3 {
                    VStack {
                        Text("点击生成爻 (第\(yaoList.count + 1)/6)")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        Spacer()
                    }
                    .padding(.top, 60)
                }
                
                // 右下角显示当前卦相
                if !yaoList.isEmpty {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("当前卦相 (\(yaoList.count)/6)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // 显示已生成的爻（从下往上，所以最新生成的爻显示在上方）
                        VStack(spacing: 2) {
                            // 显示未生成的爻位（用虚线表示，在上方）
                            ForEach(0..<(6 - yaoList.count), id: \.self) { _ in
                                Rectangle()
                                    .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                                    .frame(width: 34, height: 3)
                            }
                            
                            // 显示已生成的爻（最后生成的在上方，第一个生成的在下方）
                            ForEach(yaoList.indices.reversed(), id: \.self) { index in
                                let yao = yaoList[index]
                                HStack(spacing: 2) {
                                    if yao == 6 || yao == 8 { // 阴爻
                                        Rectangle()
                                            .fill(Color.primary)
                                            .frame(width: 15, height: 3)
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: 4, height: 3)
                                        Rectangle()
                                            .fill(Color.primary)
                                            .frame(width: 15, height: 3)
                                    } else { // 阳爻 (7, 9)
                                        Rectangle()
                                            .fill(Color.primary)
                                            .frame(width: 34, height: 3)
                                    }
                                }
                                .overlay(
                                    // 变爻标记
                                    (yao == 6 || yao == 9) ? Circle()
                                        .fill(Color.red)
                                        .frame(width: 6, height: 6) : nil
                                )
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .position(x: geometry.size.width - 70, y: geometry.size.height - 100)
                }
                
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
                    // 步骤3：分组并显示余数
                    let leftGroups = leftRemainder == 4 ? leftCount / 4 - 1 : leftCount / 4
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
                    // 步骤4：移除余数后平摊（仅第一、二轮显示，第三轮不显示此步骤）
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
                            // 前两轮加上左下角那根
                            if stepCount < 3 {
                                Rectangle()
                                    .fill(Color.brown)
                                    .frame(width: 10, height: 150)
                                    .cornerRadius(3)
                                    .shadow(radius: 2)
                            }
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
                    // 初始状态：显示49根木棍
                    ZStack {
                        HStack(alignment: .center, spacing: 6) {
                            ForEach(0..<totalSticks, id: \.self) { _ in
                                StickView()
                                    .frame(width: 4, height: geometry.size.height * 0.3)
                            }
                        }
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.5)
                        
                        // 拖拽竖线
                        if isDragging {
                            Rectangle()
                                .fill(Color.red.opacity(0.7))
                                .frame(width: 3, height: geometry.size.height * 0.6)
                                .position(x: geometry.size.width * 0.1 + (geometry.size.width * 0.8) * splitLinePosition, 
                                         y: geometry.size.height / 2)
                                .animation(.easeInOut(duration: 0.1), value: splitLinePosition)
                        }
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            .contentShape(Rectangle())
            .simultaneousGesture(
                // 拖拽手势 - 只在初始状态激活
                !isSplit ? DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        // 只在第一步（分堆）时允许拖拽
                        isDragging = true
                        let stickAreaWidth = geometry.size.width * 0.8
                        let stickAreaStartX = geometry.size.width * 0.1
                        let relativeX = value.location.x - stickAreaStartX
                        splitLinePosition = max(0.02, min(0.98, relativeX / stickAreaWidth)) // 限制在2%-98%之间
                    }
                    .onEnded { value in
                        if isDragging {
                            // 根据拖拽位置计算 splitIndex
                            let calculatedSplit = Int(splitLinePosition * Double(sticksLeft - 2)) + 1
                            let minSplit = 1
                            let maxSplit = sticksLeft - 1
                            
                            withAnimation(.easeInOut(duration: 0.6)) {
                                splitIndex = max(minSplit, min(maxSplit, calculatedSplit))
                                isSplit = true
                                leftCount = splitIndex ?? 0
                                isDragging = false
                            }
                            print("第\(stepCount)轮：分堆 splitLinePosition=\(splitLinePosition), splitIndex=\(splitIndex!), isSplit=\(isSplit), movedStick=\(movedStick), grouped=\(grouped), sticksLeft=\(sticksLeft)")
                        }
                    } : nil
            )
            // 为初始状态添加额外的点击手势，以防拖拽距离不够时仍能响应点击
            .onTapGesture {
                if !isSplit {
                    // 如果没有拖拽，点击时使用默认的中间位置分割
                    let calculatedSplit = sticksLeft / 2
                    let minSplit = 1
                    let maxSplit = sticksLeft - 1
                    
                    withAnimation(.easeInOut(duration: 0.6)) {
                        splitIndex = max(minSplit, min(maxSplit, calculatedSplit))
                        isSplit = true
                        leftCount = splitIndex ?? 0
                        splitLinePosition = 0.5
                    }
                    print("第\(stepCount)轮：点击分堆（中间位置） splitIndex=\(splitIndex!)")
                } else {
                    handleTapGesture()
                }
            }
        }
        .background(
            NavigationLink(
                destination: GuaResultView(
                    yao: yaoList, 
                    question: question,
                    onSaveAndExit: {
                        navigationManager.switchToHistoryTab()
                    }
                )
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .tabBar),
                isActive: $navigateToResult
            ) {
                EmptyView()
            }
            .hidden()
        )
    }
    
    private func handleTapGesture() {
        if isSplit && !movedStick {
            withAnimation(.easeInOut(duration: 0.6)) {
                movedStick = true
                rightCount = sticksLeft - leftCount - 1
            }
            print("第\(stepCount)轮：移棍 movedStick set to true, splitIndex=\(splitIndex!), isSplit=\(isSplit), grouped=\(grouped), sticksLeft=\(sticksLeft)")
        } else if isSplit && movedStick && !grouped {
            // 步骤2：移出一根到左下角
            withAnimation(.easeInOut(duration: 0.6)) {
                grouped = true
                leftRemainder = leftCount % 4 == 0 ? 4 : leftCount % 4
                rightRemainder = rightCount % 4 == 0 ? 4 : rightCount % 4
                removedSticks = leftRemainder + rightRemainder
                // 前两轮 sticksLeft = centerSticks（不加左下角那根）
                if stepCount < 3 {
                    centerSticks = sticksLeft - removedSticks - 1
                    sticksLeft = centerSticks // 不加左下角那根
                } else {
                    centerSticks = sticksLeft - removedSticks - 1
                    // 第三轮 sticksLeft 不再更新，直接进入爻计算
                }
            }
            print("第\(stepCount)轮：分余数 leftRemainder=\(leftRemainder), rightRemainder=\(rightRemainder), sticksLeft=\(sticksLeft)")
        } else if isSplit && movedStick && grouped {
            // 步骤4：移除余数（前两轮），第三轮生成爻
            if stepCount < 3 {
                print("第\(stepCount)轮：移除余数 红色余数数量: \(leftRemainder), 蓝色余数数量: \(rightRemainder), 当前平摊数量: \(centerSticks), sticksLeft=\(sticksLeft)")
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
                    stepCount += 1
                    isDragging = false
                    splitLinePosition = 0.5
                }
                print("User tapped again: reset, splitIndex=\(splitIndex?.description ?? "nil"), isSplit=\(isSplit), movedStick=\(movedStick), grouped=\(grouped), stepCount=\(stepCount)")
            } else {
                // 步骤5：第三轮只记录爻，不做移除余数操作
                let leftGroups = leftRemainder == 4 ? leftCount / 4 - 1 : leftCount / 4
                let rightGroups = rightRemainder == 4 ? rightCount / 4 - 1 : rightCount / 4
                let yao = leftGroups + rightGroups
                yaoList.append(yao)
                print("第3轮结束，生成爻: \(yao)，当前所有爻: \(yaoList)")
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
                    stepCount = 1
                    sticksLeft = 49 // 完全重置
                    isDragging = false
                    splitLinePosition = 0.5
                }
                print("三轮结束，已重置，准备生成下一个爻。当前所有爻: \(yaoList)")
                // 如果已生成6个爻，可在此处处理最终结果
                if yaoList.count == 6 {
                    print("全部6个爻生成完毕: \(yaoList)")
                    // 跳转到卦展示页面
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        navigateToResult = true
                    }
                }
            }
        }
    }
}

#Preview {
    SticksLayoutView(question: "我想要在年底前是否应该换工作？")
        .environmentObject(NavigationManager(switchToHistoryTab: {}))
}
