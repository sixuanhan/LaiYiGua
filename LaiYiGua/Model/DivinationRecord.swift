//
//  DivinationRecord.swift
//  LaiYiGua
//
//  Data model for saving divination records

import Foundation

enum DivinationRating: String, CaseIterable, Codable {
    case excellent = "神了"
    case average = "一般"
    case poor = "差评"

    var emoji: String {
        switch self {
        case .excellent: return "🎯"
        case .average: return "👍"
        case .poor: return "👎"
        }
    }
}

struct DivinationRecord: Identifiable, Codable {
    var id: UUID
    var question: String
    var guaName: String
    var guaURL: URL
    var originalYao: [Int]
    var changingYaoPositions: [Int]
    var interpretation: String
    var strategy: String
    var aiInterpretation: String?
    var date: Date
    var postEventRecord: String? // 事后记录
    var rating: DivinationRating? // 评价

    init(question: String, guaName: String, guaURL: URL, originalYao: [Int], changingYaoPositions: [Int], interpretation: String, strategy: String, aiInterpretation: String? = nil, rating: DivinationRating? = nil, postEventRecord: String? = nil, id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.question = question
        self.guaName = guaName
        self.guaURL = guaURL
        self.originalYao = originalYao
        self.changingYaoPositions = changingYaoPositions
        self.interpretation = interpretation
        self.strategy = strategy
        self.aiInterpretation = aiInterpretation
        self.date = date
        self.rating = rating
        self.postEventRecord = postEventRecord
    }

    var hasAIResult: Bool {
        guard let aiInterpretation else { return false }
        return !aiInterpretation.isEmpty
    }

    var aiFailed: Bool {
        guard let aiInterpretation else { return false }
        return aiInterpretation.contains("AI解卦出现错误：")
    }
}

class DivinationRecordManager: ObservableObject {
    @Published var records: [DivinationRecord] = []
    private let userDefaults = UserDefaults.standard
    private let recordsKey = "DivinationRecords"
    
    init() {
        loadRecords()
    }
    
    func saveRecord(_ record: DivinationRecord) {
        if let existingIndex = records.firstIndex(where: { $0.id == record.id }) {
            records[existingIndex] = record
            print("💾 更新已存在的占卜记录: \(record.guaName) - \(record.question)")
        } else {
            records.insert(record, at: 0) // 新记录放在最前面
            print("💾 添加新的占卜记录: \(record.guaName) - \(record.question)")
        }
        saveRecords()
    }

    func updateAIInterpretation(recordId: UUID, aiInterpretation: String?) {
        guard let index = records.firstIndex(where: { $0.id == recordId }) else {
            print("❌ 更新AI解卦失败: 未找到记录 ID \(recordId)")
            return
        }

        var updatedRecord = records[index]
        updatedRecord.aiInterpretation = aiInterpretation
        records[index] = updatedRecord
        print("🧠 更新AI解卦结果: \(updatedRecord.guaName) - \(updatedRecord.question)")
        saveRecords()
    }
    
    func updatePostEventRecord(recordId: UUID, postEventRecord: String?, rating: DivinationRating?) {
        if let index = records.firstIndex(where: { $0.id == recordId }) {
            var updatedRecord = records[index]
            updatedRecord.postEventRecord = postEventRecord
            updatedRecord.rating = rating
            records[index] = updatedRecord
            print("📝 更新事后记录: \(updatedRecord.guaName) - 评价: \(rating?.rawValue ?? "无")")
            saveRecords()
        }
    }

    func deleteRecord(at index: Int) {
        guard index < records.count else {
            print("❌ 删除记录失败: 索引 \(index) 超出范围")
            return
        }
        let deletedRecord = records[index]
        records.remove(at: index)
        print("🗑️ 删除占卜记录: \(deletedRecord.guaName) - \(deletedRecord.question)")
        saveRecords()
    }

    func deleteRecord(id: UUID) {
        guard let index = records.firstIndex(where: { $0.id == id }) else {
            print("❌ 删除记录失败: 未找到记录 ID \(id)")
            return
        }
        deleteRecord(at: index)
    }
    
    func clearAllRecords() {
        let recordCount = records.count
        records.removeAll()
        userDefaults.removeObject(forKey: recordsKey)
        print("🧹 清除所有 \(recordCount) 条占卜记录")
    }
    
    private func saveRecords() {
        do {
            let encoded = try JSONEncoder().encode(records)
            userDefaults.set(encoded, forKey: recordsKey)
            print("✅ 成功保存 \(records.count) 条占卜记录到 UserDefaults")
        } catch {
            print("❌ 保存占卜记录失败: \(error.localizedDescription)")
        }
    }
    
    private func loadRecords() {
        guard let data = userDefaults.data(forKey: recordsKey) else {
            print("📝 UserDefaults 中没有找到历史记录，使用空数组")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([DivinationRecord].self, from: data)
            records = decoded
            print("✅ 成功从 UserDefaults 加载 \(records.count) 条占卜记录")
        } catch {
            print("❌ 加载占卜记录失败: \(error.localizedDescription)")
            // 如果解码失败，清除损坏的数据
            userDefaults.removeObject(forKey: recordsKey)
        }
    }
}
