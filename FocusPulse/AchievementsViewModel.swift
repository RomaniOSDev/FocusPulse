//
//  AchievementsViewModel.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import Foundation
import Combine

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let isUnlocked: Bool
}

struct Challenge: Identifiable {
    let id: String
    let title: String
    let description: String
    let target: Int
    let progress: Int
    let isCompleted: Bool
}

final class AchievementsViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var dailyChallenge: Challenge?
    @Published var weeklyChallenge: Challenge?

    init() {
        recompute()
    }

    func recompute() {
        let sessions = SessionHistoryStorage.loadAll()
        let preferences = UserPreferencesStorage.load()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Daily stats
        let todaySessions = sessions.filter { calendar.isDate($0.startTime, inSameDayAs: today) && $0.type == .focus }
        let dailyCompleted = todaySessions.filter { $0.wasCompleted }.count

        // Weekly stats
        let weekAgo = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        let weekSessions = sessions.filter {
            $0.type == .focus && $0.startTime >= weekAgo && $0.startTime <= today.addingTimeInterval(24*60*60)
        }
        let weekCompleted = weekSessions.filter { $0.wasCompleted }.count

        // Challenges
        let daily = Challenge(
            id: "daily_sessions",
            title: "Daily focus goal",
            description: "Complete \(preferences.dailySessionGoal) focus sessions today.",
            target: preferences.dailySessionGoal,
            progress: dailyCompleted,
            isCompleted: dailyCompleted >= preferences.dailySessionGoal
        )

        let weeklyTarget = max(preferences.dailySessionGoal * 5, 10)
        let weekly = Challenge(
            id: "weekly_sessions",
            title: "Weekly focus streak",
            description: "Reach \(weeklyTarget) focus sessions this week.",
            target: weeklyTarget,
            progress: weekCompleted,
            isCompleted: weekCompleted >= weeklyTarget
        )

        dailyChallenge = daily
        weeklyChallenge = weekly

        // Achievements
        achievements = buildAchievements(from: sessions)
    }

    private func buildAchievements(from sessions: [FocusSession]) -> [Achievement] {
        var result: [Achievement] = []

        let focusSessions = sessions.filter { $0.type == .focus }
        let totalFocusSessions = focusSessions.count

        // First focus
        result.append(
            Achievement(
                id: "first_focus",
                title: "First Focus",
                description: "Complete your first focus session.",
                iconName: "1.circle.fill",
                isUnlocked: totalFocusSessions >= 1
            )
        )

        // Deep dive
        let hasLongSession = focusSessions.contains { ($0.actualDuration ?? $0.plannedDuration) >= 45 * 60 }
        result.append(
            Achievement(
                id: "deep_dive",
                title: "Deep Dive",
                description: "Stay focused for at least 45 minutes in a single session.",
                iconName: "hourglass.bottomhalf.filled",
                isUnlocked: hasLongSession
            )
        )

        // Four in a row (day)
        let calendar = Calendar.current
        var maxPerDay = 0
        let groupedByDay = Dictionary(grouping: focusSessions) { session in
            calendar.startOfDay(for: session.startTime)
        }
        for (_, daySessions) in groupedByDay {
            let completed = daySessions.filter { $0.wasCompleted }.count
            maxPerDay = max(maxPerDay, completed)
        }
        result.append(
            Achievement(
                id: "four_in_row",
                title: "Four in a Row",
                description: "Complete 4 or more focus sessions in a single day.",
                iconName: "4.circle.fill",
                isUnlocked: maxPerDay >= 4
            )
        )

        // 7-day streak
        let streak = longestStreakDays(from: focusSessions)
        result.append(
            Achievement(
                id: "week_streak",
                title: "7-Day Streak",
                description: "Keep a daily focus habit for 7 days in a row.",
                iconName: "flame.fill",
                isUnlocked: streak >= 7
            )
        )

        return result
    }

    private func longestStreakDays(from sessions: [FocusSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let uniqueDays = Set(sessions.map { calendar.startOfDay(for: $0.startTime) })
        let sorted = uniqueDays.sorted()
        var best = 1
        var current = 1
        for i in 1..<sorted.count {
            if let day = calendar.date(byAdding: .day, value: 1, to: sorted[i-1]),
               calendar.isDate(day, inSameDayAs: sorted[i]) {
                current += 1
                best = max(best, current)
            } else {
                current = 1
            }
        }
        return best
    }
}

