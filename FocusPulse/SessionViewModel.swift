//
//  SessionViewModel.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import Foundation
import UIKit
import Combine

final class SessionViewModel: ObservableObject {
    @Published var currentSession: FocusSession?
    @Published var timeRemaining: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var isFocusMode: Bool = true
    @Published var sessionsCompleted: Int = 0
    @Published var dailyGoal: Int = 8

    // Tasks & presets
    @Published var tasks: [FocusTask] = []
    @Published var currentTask: FocusTask?
    @Published var selectedPreset: PresetProfile = .lightFocus

    // Tags
    @Published var selectedTags: Set<FocusTag> = []

    // Review sheet
    @Published var isReviewPresented: Bool = false
    @Published var reviewSession: FocusSession?

    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var focusSessionsInRow: Int = 0

    private var preferences: UserPreferences

    var progress: Double {
        guard let session = currentSession else { return 0 }
        guard session.plannedDuration > 0 else { return 0 }
        return 1 - timeRemaining / session.plannedDuration
    }

    init(preferences: UserPreferences = UserPreferences()) {
        // load saved preferences on init
        self.preferences = UserPreferencesStorage.load()
        self.dailyGoal = self.preferences.dailySessionGoal
        self.tasks = TaskStorage.load()
        self.selectedPreset = .lightFocus
    }

    func startDefaultFocus() {
        // for focus sessions используем длительность из выбранного пресета
        startSession(type: .focus, duration: selectedPreset.focusDuration)
    }

    func startSession(type: SessionType, duration: TimeInterval? = nil) {
        invalidateTimer()

        // refresh preferences when using default durations
        if duration == nil {
            refreshPreferences()
        }

        let planned: TimeInterval
        if type == .focus {
            planned = duration ?? selectedPreset.focusDuration
        } else {
            planned = duration ?? defaultDuration(for: type)
        }

        var session = FocusSession(
            id: UUID(),
            type: type,
            startTime: Date(),
            plannedDuration: planned,
            actualDuration: nil,
            wasCompleted: false,
            distractionsCount: 0,
            notes: nil,
            taskId: currentTask?.id,
            preset: selectedPreset,
            tags: Array(selectedTags),
            focusRating: nil,
            distractionEvents: []
        )

        // привязываем уровень Pulse Guard к пресету
        preferences.distractionDetectionLevel = selectedPreset.distractionLevel

        currentSession = session
        timeRemaining = planned
        isRunning = true
        isFocusMode = (type == .focus)

        if type == .focus {
            focusSessionsInRow += 1
            // обновляем lastUsedAt у задачи
            if let taskIndex = tasks.firstIndex(where: { $0.id == session.taskId }) {
                tasks[taskIndex].lastUsedAt = Date()
                saveTasks()
            }
        }

        startTimer()
    }

    func pauseSession() {
        isRunning = false
        invalidateTimer()
    }

    func resumeSession() {
        guard currentSession != nil, timeRemaining > 0 else { return }
        if !isRunning {
            isRunning = true
            startTimer()
        }
    }

    func completeSession() {
        guard var session = currentSession else { return }
        invalidateTimer()
        isRunning = false
        timeRemaining = 0

        session.wasCompleted = true
        session.actualDuration = session.plannedDuration
        currentSession = session

        if session.type == .focus {
            sessionsCompleted += 1
        }

        // persist session to history
        SessionHistoryStorage.append(session)

        // show review sheet only after a full focus session
        if session.type == .focus {
            reviewSession = session
            isReviewPresented = true
        } else {
            isReviewPresented = false
        }

        scheduleNextIfNeeded(after: session.type)
    }

    func skipSession() {
        invalidateTimer()
        isRunning = false
        currentSession = nil
        timeRemaining = 0
    }

    func checkForDistractions() -> Bool {
        // Stub for DistractionDetector integration
        guard var session = currentSession else { return false }
        let event = DistractionEvent(
            id: UUID(),
            sessionId: session.id,
            timestamp: Date(),
            reason: .manual
        )
        session.distractionEvents.append(event)
        session.distractionsCount += 1
        currentSession = session
        return true
    }

    // MARK: - Tasks public API

    func addTask(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let task = FocusTask(
            id: UUID(),
            title: trimmed,
            isCompleted: false,
            notes: nil,
            createdAt: Date(),
            lastUsedAt: nil
        )
        tasks.append(task)
        saveTasks()
    }

    func toggleTaskCompletion(_ task: FocusTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
        saveTasks()
        if currentTask?.id == task.id, tasks[index].isCompleted {
            currentTask = nil
        }
    }

    func selectTask(_ task: FocusTask) {
        currentTask = task
    }

    func markCurrentTaskDone() {
        guard let current = currentTask,
              let index = tasks.firstIndex(where: { $0.id == current.id }) else { return }
        tasks[index].isCompleted = true
        saveTasks()
        currentTask = nil
    }

    func setPreset(_ preset: PresetProfile) {
        selectedPreset = preset
    }

    func applyReview(rating: Int, note: String?) {
        guard rating >= 1, rating <= 5 else { return }
        guard var session = currentSession else { return }
        session.focusRating = rating
        session.notes = (note?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? note : session.notes
        currentSession = session

        // обновляем последнюю сессию в истории
        var all = SessionHistoryStorage.loadAll()
        if let index = all.lastIndex(where: { $0.id == session.id }) {
            all[index] = session
            SessionHistoryStorage.save(all)
        }

        isReviewPresented = false
    }

    // MARK: - Private

    private func startTimer() {
        registerBackgroundTask()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            guard self.isRunning else { return }

            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.completeSession()
            }
        }
    }

    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
        endBackgroundTask()
    }

    private func defaultDuration(for type: SessionType) -> TimeInterval {
        switch type {
        case .focus: return preferences.focusDuration
        case .shortBreak: return preferences.shortBreakDuration
        case .longBreak: return preferences.longBreakDuration
        }
    }

    private func scheduleNextIfNeeded(after type: SessionType) {
        // Если дневная цель по фокус-сессиям уже достигнута,
        // больше автоматически новые интервалы не запускаем.
        if sessionsCompleted >= dailyGoal {
            currentSession = nil
            isRunning = false
            timeRemaining = 0
            return
        }

        switch type {
        case .focus:
            let nextType: SessionType = (focusSessionsInRow % preferences.sessionsBeforeLongBreak == 0)
            ? .longBreak
            : .shortBreak
            isFocusMode = false
            startSession(type: nextType)
        case .shortBreak, .longBreak:
            isFocusMode = true
            startSession(type: .focus)
        }
    }

    private func refreshPreferences() {
        preferences = UserPreferencesStorage.load()
        dailyGoal = preferences.dailySessionGoal
    }

    private func saveTasks() {
        TaskStorage.save(tasks)
    }

    // Toggle tag from UI
    func toggleTag(_ tag: FocusTag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    private func registerBackgroundTask() {
        endBackgroundTask()
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "com.focuspulse.timer") { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}

