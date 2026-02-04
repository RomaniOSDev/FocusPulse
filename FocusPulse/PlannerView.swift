//
//  PlannerView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI
import Combine

final class PlannerViewModel: ObservableObject {
    @Published var blocks: [FocusPlanBlock] = []

    init() {
        blocks = PlannerStorage.load()
    }

    func addBlock(start: Date, durationMinutes: Int, preset: PresetProfile, taskId: UUID?) {
        let end = Calendar.current.date(byAdding: .minute, value: durationMinutes, to: start) ?? start
        let block = FocusPlanBlock(
            id: UUID(),
            startTime: start,
            endTime: end,
            preset: preset,
            taskId: taskId,
            isCompleted: false
        )
        blocks.append(block)
        save()
    }

    func toggleCompleted(_ block: FocusPlanBlock) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else { return }
        blocks[index].isCompleted.toggle()
        save()
    }

    private func save() {
        PlannerStorage.save(blocks)
    }
}

struct PlannerView: View {
    @StateObject private var viewModel = PlannerViewModel()
    let tasks: [FocusTask]

    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate: Date = Date()
    @State private var selectedPreset: PresetProfile = .lightFocus
    @State private var selectedTaskId: UUID?
    @State private var durationMinutes: Int = 25

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Form {
                    Section(header: Text("New focus block")) {
                        DatePicker("Start time", selection: $selectedDate, displayedComponents: [.hourAndMinute])

                        Picker("Preset", selection: $selectedPreset) {
                            ForEach(PresetProfile.allCases) { preset in
                                Text(preset.name).tag(preset)
                            }
                        }

                        Picker("Task", selection: Binding(
                            get: { selectedTaskId ?? UUID() },
                            set: { newValue in
                                selectedTaskId = tasks.first(where: { $0.id == newValue })?.id
                            })) {
                            Text("None").tag(UUID())
                            ForEach(tasks) { task in
                                Text(task.title).tag(task.id)
                            }
                        }

                        Stepper(value: $durationMinutes, in: 10...120, step: 5) {
                            Text("Duration: \(durationMinutes) min")
                        }

                        Button("Add block") {
                            let taskId = selectedTaskId
                            viewModel.addBlock(start: selectedDate, durationMinutes: durationMinutes, preset: selectedPreset, taskId: taskId)
                        }
                    }

                    Section(header: Text("Today")) {
                        let todayBlocks = viewModel.blocks.filter { Calendar.current.isDate($0.startTime, inSameDayAs: Date()) }
                        if todayBlocks.isEmpty {
                            Text("No focus blocks planned for today.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(todayBlocks) { block in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(block.preset.name)
                                        Text(timeRange(for: block))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button {
                                        viewModel.toggleCompleted(block)
                                    } label: {
                                        Image(systemName: block.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(block.isCompleted ? .green : .gray)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Planner")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func timeRange(for block: FocusPlanBlock) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: block.startTime)) – \(formatter.string(from: block.endTime))"
    }
}

