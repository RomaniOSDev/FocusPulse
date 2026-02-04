//
//  TaskSelectionView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

struct TaskSelectionView: View {
    @ObservedObject var viewModel: SessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var newTaskTitle: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("New task")) {
                        HStack {
                            TextField("Task title", text: $newTaskTitle)
                            Button("Add") {
                                viewModel.addTask(title: newTaskTitle)
                                newTaskTitle = ""
                            }
                            .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }

                    Section(header: Text("Tasks")) {
                        if viewModel.tasks.isEmpty {
                            Text("No tasks yet. Create your first task above.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(viewModel.tasks) { task in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(task.title)
                                            .strikethrough(task.isCompleted)
                                        if viewModel.currentTask?.id == task.id {
                                            Text("Current")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    Spacer()
                                    if !task.isCompleted {
                                        Button("Select") {
                                            viewModel.selectTask(task)
                                            dismiss()
                                        }
                                    }
                                    Button {
                                        viewModel.toggleTaskCompletion(task)
                                    } label: {
                                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(task.isCompleted ? .green : .gray)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

