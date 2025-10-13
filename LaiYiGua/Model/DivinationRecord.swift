//
//  DivinationRecord.swift
//  LaiYiGua
//
//  Data model for saving divination records

import Foundation

struct DivinationRecord: Identifiable, Codable {
    let id = UUID()
    let question: String
    let guaName: String
    let guaURL: URL
    let originalYao: [Int]
    let changingYaoPositions: [Int]
    let interpretation: String
    let strategy: String
    let date: Date
    
    init(question: String, guaName: String, guaURL: URL, originalYao: [Int], changingYaoPositions: [Int], interpretation: String, strategy: String) {
        self.question = question
        self.guaName = guaName
        self.guaURL = guaURL
        self.originalYao = originalYao
        self.changingYaoPositions = changingYaoPositions
        self.interpretation = interpretation
        self.strategy = strategy
        self.date = Date()
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
        records.insert(record, at: 0) // 新记录放在最前面
        print("💾 添加新的占卜记录: \(record.guaName) - \(record.question)")
        saveRecords()
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
