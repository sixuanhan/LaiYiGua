//  HistoryView.swift
//  LaiYiGua
//  历史记录页面
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var recordManager: DivinationRecordManager
    @State private var selectedRecord: DivinationRecord?
    
    var body: some View {
        NavigationView {
            VStack {
                if recordManager.records.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("暂无历史记录")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("完成占卜后点击‘保存’按钮\n即可在此查看历史记录")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(recordManager.records) { record in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Spacer()
                                    Text(formatDate(record.date))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Text(record.question)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)

                                HStack {
                                    Text(record.guaName)
                                        .font(.body)
                                        .foregroundColor(.secondary)

                                    // AI解卦标识
                                    if record.aiInterpretation != nil && !record.aiInterpretation!.isEmpty {
                                        Image(systemName: "brain.head.profile")
                                            .font(.caption)
                                            .foregroundColor(.purple)
                                    }
                                    
                                    // 评价标识
                                    if let rating = record.rating {
                                        Text(rating.emoji)
                                            .font(.caption)
                                    }

                                    Spacer()
                                }
                                
                                Text(record.strategy)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedRecord = record
                            }
                        }
                        .onDelete(perform: deleteRecords)
                    }
                }
            }
            .navigationTitle("历史记录")
            .sheet(item: $selectedRecord) { record in
                NavigationView {
                    GuaDetailView(record: record, showSaveButton: false)
                }
            }
        }
    }
    
    private func deleteRecords(at offsets: IndexSet) {
        for index in offsets {
            recordManager.deleteRecord(at: index)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
        .environmentObject(DivinationRecordManager())
}
