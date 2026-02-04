//
//  CircularTimerView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

struct CircularTimerView: View {
    let progress: Double
    let color: Color
    let timeRemaining: TimeInterval
    let isRunning: Bool

    let startAction: () -> Void
    let pauseAction: () -> Void
    let resumeAction: () -> Void
    let completeAction: () -> Void

    @State private var pulse: Bool = false

    private var formattedTime: String {
        let total = max(Int(timeRemaining), 0)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 16)

            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    LinearGradient(
                        colors: [
                            color.opacity(0.9),
                            color.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.9), radius: 18, x: 0, y: 10)
                .animation(.easeInOut(duration: 0.4), value: progress)

            Circle()
                .fill(color.opacity(0.12))
                .scaleEffect(pulse ? 1.04 : 0.96)
                .blur(radius: 8)
                .animation(
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: pulse
                )

            VStack(spacing: 8) {
                Text(formattedTime)
                    .font(.system(size: 40, weight: .medium, design: .rounded))
                    .foregroundColor(.white)

                controlButtons
            }
        }
        .onAppear { pulse = true }
    }

    @ViewBuilder
    private var controlButtons: some View {
        HStack(spacing: 16) {
            if timeRemaining <= 0 || (!isRunning && progress == 0) {
                Button(action: startAction) {
                    Text("Start")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.background)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [
                                    color,
                                    color.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(999)
                        .shadow(color: color.opacity(0.9), radius: 12, x: 0, y: 6)
                }
            } else {
                if isRunning {
                    Button(action: pauseAction) {
                        Text("Pause")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.10))
                            .cornerRadius(999)
                            .shadow(color: Color.black.opacity(0.45), radius: 8, x: 0, y: 5)
                    }
                } else {
                    Button(action: resumeAction) {
                        Text("Resume")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.10))
                            .cornerRadius(999)
                            .shadow(color: Color.black.opacity(0.45), radius: 8, x: 0, y: 5)
                    }
                }

                Button(role: .destructive, action: completeAction) {
                    Text("Finish")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(999)
                        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)
                }
            }
        }
    }
}

