//
//  AchievementsView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var viewModel = AchievementsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Challenges")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.white)

            if let daily = viewModel.dailyChallenge {
                challengeRow(challenge: daily)
            }
            if let weekly = viewModel.weeklyChallenge {
                challengeRow(challenge: weekly)
            }

            Text("Achievements")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 8)

            if viewModel.achievements.isEmpty {
                Text("Complete focus sessions to unlock achievements.")
                    .foregroundColor(.white.opacity(0.6))
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(viewModel.achievements) { achievement in
                        achievementCard(achievement)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(AppTheme.background.ignoresSafeArea())
    }

    private func challengeRow(challenge: Challenge) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(challenge.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                if challenge.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(AppTheme.breakAccent)
                }
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
                    .fill(AppTheme.focusAccent)
                    .frame(width: nil, height: 6)
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
                            Color.white.opacity(0.10),
                            Color.white.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 8)
    }

    private func achievementCard(_ achievement: Achievement) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: achievement.iconName)
                    .foregroundColor(achievement.isUnlocked ? AppTheme.breakAccent : .gray)
                    .font(.title3)
                Spacer()
            }
            Text(achievement.title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(achievement.isUnlocked ? AppTheme.breakAccent : Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.45), radius: 12, x: 0, y: 8)
    }
}

