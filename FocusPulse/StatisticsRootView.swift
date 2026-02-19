//
//  StatisticsRootView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

struct StatisticsRootView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    @State private var showPlanner = false

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            TabView {
                todayView
                    .padding()

                weekView
                    .padding()

                achievementsView
                    .padding()
            }
            .tabViewStyle(.page)
        }
        .sheet(isPresented: $showPlanner) {
            PlannerView(tasks: [])
        }
    }

    private var todayView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(AppTheme.breakAccent)
                Text("Today")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }

            HStack(spacing: 12) {
                MetricCard(
                    title: "Focus hours",
                    value: String(format: "%.1f", viewModel.todayStats.focusTime / 3600),
                    color: AppTheme.focusAccent
                )
                MetricCard(
                    title: "Sessions",
                    value: "\(viewModel.todayStats.sessionsCompleted)",
                    color: AppTheme.breakAccent
                )
            }

            // Tags context row
            if !viewModel.topTagsToday.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("By context")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.8))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.topTagsToday.prefix(4), id: \.0.id) { tag, time in
                                let hours = time / 3600
                                Text("\(tag.title) · \(String(format: "%.1f", hours))h")
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.12))
                                    )
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Focus trend")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.8))

                LineChartView(data: mockDailySeries(), color: AppTheme.focusAccent)
                    .frame(height: 180)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.06),
                                        Color.white.opacity(0.02)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: Color.black.opacity(0.45), radius: 16, x: 0, y: 12)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Insights")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))

                ForEach(viewModel.insights) { insight in
                    Text("• \(insight.text)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            if !viewModel.recentNotes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Highlights")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.85))
                    ForEach(viewModel.recentNotes) { session in
                        if let notes = session.notes {
                            Text("• \(notes)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.75))
                        }
                    }
                }
            }

            Button {
                showPlanner = true
            } label: {
                Text("Open planner")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.background)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.focusAccent, AppTheme.focusAccent.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(999)
                    .shadow(color: AppTheme.focusAccent.opacity(0.9), radius: 10, x: 0, y: 6)
            }

            Spacer()
        }
    }

    private var achievementsView: some View {
        AchievementsView()
    }

    private var weekView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundColor(AppTheme.focusAccent)
                Text("This week")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Weekly focus blocks")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.8))

                BarChartView(data: mockWeeklySeries())
                    .frame(height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.06),
                                        Color.white.opacity(0.02)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: Color.black.opacity(0.45), radius: 16, x: 0, y: 12)
            }

            // Streaks & season summary
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    MetricCard(
                        title: "Current streak (days)",
                        value: "\(viewModel.currentStreakDays)",
                        color: AppTheme.focusAccent
                    )
                    MetricCard(
                        title: "Best streak (days)",
                        value: "\(viewModel.bestStreakDays)",
                        color: AppTheme.breakAccent
                    )
                }

                if viewModel.monthTotalFocusTime > 0 {
                    monthSummaryView
                }
            }

            Spacer()
        }
    }

    private func mockDailySeries() -> [Double] {
        [0.5, 1.2, 1.8, 2.3, 1.7, 2.5, 1.1]
    }

    private func mockWeeklySeries() -> [Double] {
        [2.0, 2.5, 3.0, 1.5, 2.8, 2.2, 1.9]
    }

    private var monthSummaryView: some View {
        let hours = viewModel.monthTotalFocusTime / 3600
        let hoursString = String(format: "%.1f", hours)
        let sessions = viewModel.monthSessionsCount

        let bestDayText: String? = {
            guard let bestDay = viewModel.monthBestDay else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "Best focus day: \(formatter.string(from: bestDay))."
        }()

        return VStack(alignment: .leading, spacing: 4) {
            Text("This month: \(hoursString)h across \(sessions) focus sessions.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            if let best = bestDayText {
                Text(best)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

