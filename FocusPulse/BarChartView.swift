//
//  BarChartView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

struct BarChartView: View {
    let data: [Double]

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let maxValue = (data.max() ?? 1)
            let barWidth = data.isEmpty ? 0 : width / CGFloat(data.count) * 0.6

            HStack(alignment: .bottom, spacing: width * 0.4 / CGFloat(max(data.count, 1))) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    let barHeight = CGFloat(value / maxValue) * height
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.focusAccent,
                                    AppTheme.focusAccent.opacity(0.5)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: barWidth, height: barHeight)
                        .shadow(color: AppTheme.focusAccent.opacity(0.7), radius: 6, x: 0, y: 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

