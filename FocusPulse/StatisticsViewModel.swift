//
//  StatisticsViewModel.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import Foundation
import Combine

struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    let focusTime: TimeInterval
    let sessionsCompleted: Int
    let distractions: Int
}

struct Insight: Identifiable {
    let id = UUID()
    let text: String
}

final class StatisticsViewModel: ObservableObject {
    @Published var todayStats: DailyStats
    @Published var weekStats: [DailyStats]
    @Published var insights: [Insight] = []

    // Streaks & season
    @Published var currentStreakDays: Int = 0
    @Published var bestStreakDays: Int = 0
    @Published var topTagsToday: [(FocusTag, TimeInterval)] = []
    @Published var recentNotes: [FocusSession] = []
    @Published var monthTotalFocusTime: TimeInterval = 0
    @Published var monthSessionsCount: Int = 0
    @Published var monthBestDay: Date?

    private var allSessions: [FocusSession] = []

    init() {
        let now = Date()
        allSessions = SessionHistoryStorage.loadAll()
        if allSessions.isEmpty {
            let today = DailyStats(
                date: now,
                focusTime: 2.5 * 3600,
                sessionsCompleted: 6,
                distractions: 3
            )
            todayStats = today
            weekStats = [today]
            generateInsights()
        } else {
            let calendar = Calendar.current
            let todayDate = calendar.startOfDay(for: now)
            let todaySessions = allSessions.filter {
                calendar.isDate($0.startTime, inSameDayAs: todayDate)
            }

            let todayFocusTime = todaySessions
                .filter { $0.type == .focus }
                .reduce(0) { $0 + ($1.actualDuration ?? 0) }
            let todayCompleted = todaySessions.filter { $0.type == .focus && $0.wasCompleted }.count
            let todayDistractions = todaySessions.reduce(0) { $0 + $1.distractionsCount }

            todayStats = DailyStats(
                date: todayDate,
                focusTime: todayFocusTime,
                sessionsCompleted: todayCompleted,
                distractions: todayDistractions
            )

            var week: [DailyStats] = []
            for offset in 0..<7 {
                if let day = calendar.date(byAdding: .day, value: -offset, to: todayDate) {
                    let sessions = allSessions.filter { calendar.isDate($0.startTime, inSameDayAs: day) }
                    guard !sessions.isEmpty else { continue }

                    let focusTime = sessions
                        .filter { $0.type == .focus }
                        .reduce(0) { $0 + ($1.actualDuration ?? 0) }
                    let completed = sessions.filter { $0.type == .focus && $0.wasCompleted }.count
                    let distractions = sessions.reduce(0) { $0 + $1.distractionsCount }

                    week.append(DailyStats(
                        date: day,
                        focusTime: focusTime,
                        sessionsCompleted: completed,
                        distractions: distractions
                    ))
                }
            }
            weekStats = week.sorted { $0.date < $1.date }
            computeStreaksAndSeason()
            computeTagContext(todaySessions: todaySessions)
            computeRecentNotes()
            generateInsights()
        }
    }

    func loadData() {
        allSessions = SessionHistoryStorage.loadAll()
        // simple re-init to recompute stats
        let _ = StatisticsViewModel()
    }

    func generateInsights() {
        var newInsights: [Insight] = []
        let calendar = Calendar.current

        // Most productive weekday
        var focusByWeekday: [Int: TimeInterval] = [:]
        for session in allSessions where session.type == .focus {
            let weekday = calendar.component(.weekday, from: session.startTime)
            focusByWeekday[weekday, default: 0] += session.actualDuration ?? session.plannedDuration
        }

        if let best = focusByWeekday.max(by: { $0.value < $1.value }) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "EEEE"
            let weekdayDate = calendar.date(from: DateComponents(weekday: best.key)) ?? Date()
            let weekdayName = formatter.string(from: weekdayDate)
            newInsights.append(Insight(text: "You are most productive on \(weekdayName)s."))
        }

        // Influence of number of sessions on rating
        let focusSessions = allSessions.filter { $0.type == .focus }
        if focusSessions.count >= 4 {
            let firstThree = focusSessions.prefix(3)
            let rest = focusSessions.dropFirst(3)
            let avgFirst = averageRating(for: Array(firstThree))
            let avgRest = averageRating(for: Array(rest))
            if let a = avgFirst, let b = avgRest, a > 0, b > 0, b < a {
                let drop = Int((1 - b / a) * 100)
                newInsights.append(
                    Insight(text: "After 3 focus sessions your focus quality tends to drop by about \(drop)%.")
                )
            }
        }

        // Distractions summary
        let totalDistractions = focusSessions.reduce(0) { $0 + $1.distractionsCount }
        if totalDistractions > 0 {
            newInsights.append(
                Insight(text: "You had \(totalDistractions) distractions logged across your recent focus sessions.")
            )
        }

        if newInsights.isEmpty {
            newInsights.append(
                Insight(text: "Start logging more focus sessions to unlock deeper insights.")
            )
        }

        insights = newInsights
    }

    func exportData() {
        // TODO: export to file / share sheet
    }

    private func averageRating(for sessions: [FocusSession]) -> Double? {
        let ratings = sessions.compactMap { $0.focusRating }
        guard !ratings.isEmpty else { return nil }
        let sum = ratings.reduce(0, +)
        return Double(sum) / Double(ratings.count)
    }

    private func computeStreaksAndSeason() {
        let focusSessions = allSessions.filter { $0.type == .focus && $0.wasCompleted }
        guard !focusSessions.isEmpty else {
            currentStreakDays = 0
            bestStreakDays = 0
            return
        }

        let calendar = Calendar.current
        let uniqueDays = Set(focusSessions.map { calendar.startOfDay(for: $0.startTime) })
        let sorted = uniqueDays.sorted()

        var best = 1
        var current = 1
        for i in 1..<sorted.count {
            if let prev = calendar.date(byAdding: .day, value: 1, to: sorted[i - 1]),
               calendar.isDate(prev, inSameDayAs: sorted[i]) {
                current += 1
                best = max(best, current)
            } else {
                current = 1
            }
        }

        bestStreakDays = best

        // current streak: считаем от сегодняшнего дня назад
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var dateCursor = today
        while uniqueDays.contains(dateCursor) {
            streak += 1
            if let prev = calendar.date(byAdding: .day, value: -1, to: dateCursor) {
                dateCursor = prev
            } else {
                break
            }
        }
        currentStreakDays = streak

        // Season (current month)
        let components = calendar.dateComponents([.year, .month], from: today)
        guard let startOfMonth = calendar.date(from: components),
              let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return
        }

        let monthSessions = focusSessions.filter { $0.startTime >= startOfMonth && $0.startTime < startOfNextMonth }
        monthTotalFocusTime = monthSessions.reduce(0) { $0 + ($1.actualDuration ?? $1.plannedDuration) }
        monthSessionsCount = monthSessions.count

        // best day in month
        var focusByDay: [Date: TimeInterval] = [:]
        for s in monthSessions {
            let day = calendar.startOfDay(for: s.startTime)
            focusByDay[day, default: 0] += s.actualDuration ?? s.plannedDuration
        }
        monthBestDay = focusByDay.max(by: { $0.value < $1.value })?.key
    }

    private func computeTagContext(todaySessions: [FocusSession]) {
        let focusToday = todaySessions.filter { $0.type == .focus }
        var timeByTag: [FocusTag: TimeInterval] = [:]
        for session in focusToday {
            let duration = session.actualDuration ?? session.plannedDuration
            for tag in session.tags {
                timeByTag[tag, default: 0] += duration
            }
        }
        topTagsToday = timeByTag.sorted { $0.value > $1.value }
    }

    private func computeRecentNotes() {
        let withNotes = allSessions
            .filter { ($0.notes?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) }
            .sorted { $0.startTime > $1.startTime }
        recentNotes = Array(withNotes.prefix(3))
    }
}

