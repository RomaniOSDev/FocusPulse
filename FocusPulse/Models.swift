//
//  Models.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import Foundation

enum SessionType: String, Codable {
    case focus
    case shortBreak
    case longBreak
    
    var defaultDuration: TimeInterval {
        switch self {
        case .focus: return 25 * 60
        case .shortBreak: return 5 * 60
        case .longBreak: return 15 * 60
        }
    }
    
    var colorHex: String {
        switch self {
        case .focus: return "1475E1"
        case .shortBreak, .longBreak: return "16FF16"
        }
    }
    
    var title: String {
        switch self {
        case .focus: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
}

// MARK: - Focus session and related models

struct FocusSession: Identifiable, Codable {
    let id: UUID
    let type: SessionType
    let startTime: Date
    let plannedDuration: TimeInterval
    var actualDuration: TimeInterval?
    var wasCompleted: Bool
    var distractionsCount: Int
    var notes: String?
    
    // Task & preset linking
    var taskId: UUID?
    var preset: PresetProfile = .lightFocus
    
    // Results and distractions
    var focusRating: Int?
    var distractionEvents: [DistractionEvent] = []
}

struct DistractionEvent: Identifiable, Codable {
    let id: UUID
    let sessionId: UUID
    let timestamp: Date
    let reason: DistractionReason
}

enum DistractionReason: String, Codable, CaseIterable, Identifiable {
    case movement
    case appSwitch
    case inactivity
    case manual
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .movement: return "Movement"
        case .appSwitch: return "App switch"
        case .inactivity: return "Inactivity"
        case .manual: return "Manual"
        }
    }
}

// MARK: - Daily goal / preferences

struct DailyGoal: Codable {
    let date: Date
    var targetSessions: Int
    var completedSessions: Int
    var totalFocusTime: TimeInterval
    
    var completionPercentage: Double {
        guard targetSessions > 0 else { return 0 }
        return Double(completedSessions) / Double(targetSessions)
    }
}

enum DistractionLevel: String, Codable, CaseIterable, Identifiable {
    case relaxed
    case medium
    case strict
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .relaxed: return "Relaxed"
        case .medium: return "Medium"
        case .strict: return "Strict"
        }
    }
}

// MARK: - Presets

enum PresetProfile: String, Codable, CaseIterable, Identifiable {
    case deepWork
    case lightFocus
    case study
    case sprint
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .deepWork: return "Deep Work"
        case .lightFocus: return "Light Focus"
        case .study: return "Study"
        case .sprint: return "Sprint"
        }
    }
    
    var description: String {
        switch self {
        case .deepWork: return "50 min focus · 10 min break · strict guard"
        case .lightFocus: return "25 min focus · 5 min break · medium guard"
        case .study: return "40 min focus · 10 min break · medium guard"
        case .sprint: return "15 min focus · 3 min break · relaxed guard"
        }
    }
    
    var focusDuration: TimeInterval {
        switch self {
        case .deepWork: return 50 * 60
        case .lightFocus: return 25 * 60
        case .study: return 40 * 60
        case .sprint: return 15 * 60
        }
    }
    
    var shortBreakDuration: TimeInterval {
        switch self {
        case .deepWork: return 10 * 60
        case .lightFocus: return 5 * 60
        case .study: return 10 * 60
        case .sprint: return 3 * 60
        }
    }
    
    var longBreakDuration: TimeInterval {
        switch self {
        case .deepWork: return 20 * 60
        case .lightFocus: return 15 * 60
        case .study: return 20 * 60
        case .sprint: return 15 * 60
        }
    }
    
    var distractionLevel: DistractionLevel {
        switch self {
        case .deepWork: return .strict
        case .lightFocus: return .medium
        case .study: return .medium
        case .sprint: return .relaxed
        }
    }
}

struct UserPreferences: Codable {
    var focusDuration: TimeInterval = 25 * 60
    var shortBreakDuration: TimeInterval = 5 * 60
    var longBreakDuration: TimeInterval = 15 * 60
    var sessionsBeforeLongBreak: Int = 4
    var dailySessionGoal: Int = 8
    var isSoundEnabled: Bool = true
    var isVibrationEnabled: Bool = true
    var distractionDetectionLevel: DistractionLevel = .medium
}

// MARK: - Tasks

struct FocusTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var notes: String?
    let createdAt: Date
    var lastUsedAt: Date?
}

// MARK: - Planner

struct FocusPlanBlock: Identifiable, Codable {
    let id: UUID
    var startTime: Date
    var endTime: Date
    var preset: PresetProfile
    var taskId: UUID?
    var isCompleted: Bool
}

