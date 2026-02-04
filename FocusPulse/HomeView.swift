//
//  HomeView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    @ObservedObject var statisticsViewModel: StatisticsViewModel
    let onStartFocus: () -> Void

    @StateObject private var achievementsViewModel = AchievementsViewModel()
    @State private var showPrepareSheet = false

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    quickStartCard
                    todaySummarySection
                    challengesPreviewSection
                }
                .padding()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.focusAccent, AppTheme.breakAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .shadow(color: AppTheme.focusAccent.opacity(0.6), radius: 12, x: 0, y: 8)
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(AppTheme.background)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Focus Pulse")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text("Deep focus. Natural rhythm.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()
        }
    }

    private var quickStartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ready to focus?")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Start a new \(sessionViewModel.selectedPreset.name) session.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "timer.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.focusAccent)
            }

            Button {
                showPrepareSheet = true
            } label: {
                Text("Start focus")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppTheme.focusAccent)
                    .cornerRadius(14)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.45), radius: 18, x: 0, y: 14)
        .sheet(isPresented: $showPrepareSheet) {
            PrepareForFocusView {
                onStartFocus()
            }
        }
    }

    private var todaySummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))

            HStack(spacing: 12) {
                summaryCard(
                    icon: "clock.arrow.circlepath",
                    title: "Focus hours",
                    value: String(format: "%.1f", statisticsViewModel.todayStats.focusTime / 3600)
                )

                summaryCard(
                    icon: "target",
                    title: "Sessions",
                    value: "\(statisticsViewModel.todayStats.sessionsCompleted)"
                )
            }
        }
    }

    private func summaryCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.breakAccent)
                Spacer()
            }
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 10)
    }

    private var challengesPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Challenges")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))

            if let daily = achievementsViewModel.dailyChallenge {
                challengePreviewRow(challenge: daily, accent: AppTheme.focusAccent)
            }

            if let weekly = achievementsViewModel.weeklyChallenge {
                challengePreviewRow(challenge: weekly, accent: AppTheme.breakAccent)
            }
        }
    }

    private func challengePreviewRow(challenge: Challenge, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(challenge.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                if challenge.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(accent)
                }
                Spacer()
            }
            Text(challenge.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            let ratio = min(1.0, Double(challenge.progress) / Double(max(challenge.target, 1)))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 6)
                Capsule()
                    .fill(accent)
                    .frame(height: 6)
                    .mask(
                        GeometryReader { proxy in
                            Rectangle()
                                .frame(width: proxy.size.width * CGFloat(ratio))
                        }
                    )
            }

            Text("\(challenge.progress) / \(challenge.target)")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 8)
    }
}

