//
//  FocusSessionView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

struct FocusSessionView: View {
    @ObservedObject var viewModel: SessionViewModel

    @State private var showTaskSheet = false
    @State private var showPresetSheet = false
    @State private var showPrepareSheet = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack {
                Text(viewModel.isFocusMode ? "FOCUS" : "BREAK")
                    .font(.system(size: 24, weight: .light, design: .rounded))
                    .foregroundColor(viewModel.isFocusMode ? AppTheme.focusAccent : AppTheme.breakAccent)
                    .opacity(0.8)
                    .padding(.top, 32)

                Spacer()

                CircularTimerView(
                    progress: viewModel.progress,
                    color: viewModel.isFocusMode ? AppTheme.focusAccent : AppTheme.breakAccent,
                    timeRemaining: viewModel.timeRemaining,
                    isRunning: viewModel.isRunning,
                    startAction: { showPrepareSheet = true },
                    pauseAction: { viewModel.pauseSession() },
                    resumeAction: { viewModel.resumeSession() },
                    completeAction: { viewModel.completeSession() }
                )
                .frame(width: 260, height: 260)

                Spacer()

                // Current task & preset
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current task")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            if let task = viewModel.currentTask {
                                Text(task.title)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            } else {
                                Text("No task selected")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        Spacer()
                        if viewModel.currentTask != nil {
                            Button("Done") { viewModel.markCurrentTaskDone() }
                                .font(.caption)
                                .foregroundColor(AppTheme.breakAccent)
                        }
                        Button("Tasks") { showTaskSheet = true }
                            .font(.caption)
                            .foregroundColor(AppTheme.focusAccent)
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Preset")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            Text(viewModel.selectedPreset.name)
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button("Change") { showPresetSheet = true }
                            .font(.caption)
                            .foregroundColor(AppTheme.breakAccent)
                    }

                    // Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(FocusTag.allCases, id: \.id) { tag in
                                let isSelected = viewModel.selectedTags.contains(tag)
                                Text(tag.title)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(
                                                isSelected
                                                ? LinearGradient(
                                                    colors: [AppTheme.focusAccent, AppTheme.focusAccent.opacity(0.7)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                  )
                                                : LinearGradient(
                                                    colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                  )
                                            )
                                    )
                                    .foregroundColor(isSelected ? AppTheme.background : .white.opacity(0.8))
                                    .onTapGesture {
                                        viewModel.toggleTag(tag)
                                    }
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)

                Spacer()

                DailyProgressView(
                    sessionsCompleted: viewModel.sessionsCompleted,
                    totalSessions: viewModel.dailyGoal
                )
                .frame(height: 4)
                .padding(.horizontal, 40)
                .padding(.bottom, 32)
            }
            .padding()
        }
        .sheet(isPresented: $showTaskSheet) {
            TaskSelectionView(viewModel: viewModel)
        }
        .sheet(isPresented: $showPresetSheet) {
            PresetPickerView(viewModel: viewModel)
        }
        .sheet(isPresented: $showPrepareSheet) {
            PrepareForFocusView {
                viewModel.startDefaultFocus()
            }
        }
        .sheet(isPresented: $viewModel.isReviewPresented) {
            SessionReviewView { rating, note in
                viewModel.applyReview(rating: rating, note: note)
            }
        }
    }
}

