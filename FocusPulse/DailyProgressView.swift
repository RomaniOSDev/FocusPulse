//
//  DailyProgressView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

struct DailyProgressView: View {
    let sessionsCompleted: Int
    let totalSessions: Int

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let clampedCompleted = min(sessionsCompleted, totalSessions)
            let ratio = totalSessions > 0 ? CGFloat(clampedCompleted) / CGFloat(totalSessions) : 0

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.08))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.focusAccent,
                                AppTheme.focusAccent.opacity(0.6)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width * ratio)
                    .shadow(color: AppTheme.focusAccent.opacity(0.7), radius: 6, x: 0, y: 3)
            }
        }
    }
}

