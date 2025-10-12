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
        saveRecords()
    }
    
    func deleteRecord(at index: Int) {
        guard index < records.count else { return }
        records.remove(at: index)
        saveRecords()
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            userDefaults.set(encoded, forKey: recordsKey)
        }
    }
    
    private func loadRecords() {
        if let data = userDefaults.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([DivinationRecord].self, from: data) {
            records = decoded
        }
    }
}
