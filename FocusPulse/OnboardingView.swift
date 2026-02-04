//
//  OnboardingView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var pageIndex: Int = 0

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack {
                TabView(selection: $pageIndex) {
                    onboardingPage(
                        icon: "timer.circle.fill",
                        title: "Deep focus sessions",
                        text: "Set clear focus blocks with natural breaks and minimal distraction."
                    )
                    .tag(0)

                    onboardingPage(
                        icon: "chart.bar.fill",
                        title: "Know your rhythm",
                        text: "Track daily and weekly focus patterns to learn when you are at your best."
                    )
                    .tag(1)

                    onboardingPage(
                        icon: "bolt.heart.fill",
                        title: "Protect your attention",
                        text: "Use Pulse Guard, tasks, presets and rituals to keep attention where it matters."
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))

                HStack {
                    Button("Skip") {
                        onFinish()
                    }
                    .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    Button(pageIndex == 2 ? "Get started" : "Next") {
                        if pageIndex < 2 {
                            withAnimation {
                                pageIndex += 1
                            }
                        } else {
                            onFinish()
                        }
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.background)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.focusAccent, AppTheme.focusAccent.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(999)
                    .shadow(color: AppTheme.focusAccent.opacity(0.9), radius: 14, x: 0, y: 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
    }

    private func onboardingPage(icon: String, title: String, text: String) -> some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.focusAccent, AppTheme.breakAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .shadow(color: AppTheme.focusAccent.opacity(0.8), radius: 30, x: 0, y: 20)

                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.background)
            }

            VStack(alignment: .center, spacing: 8) {
                Text(title)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
    }
}

