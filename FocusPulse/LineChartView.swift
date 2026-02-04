//
//  LineChartView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

struct LineChartView: View {
    let data: [Double]
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let maxValue = (data.max() ?? 1)
            let stepX = data.count > 1 ? width / CGFloat(data.count - 1) : 0

            // заполненная подложка
            Path { path in
                for (index, value) in data.enumerated() {
                    let x = CGFloat(index) * stepX
                    let y = height - CGFloat(value / maxValue) * height
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: height))
                        path.addLine(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    if index == data.count - 1 {
                        path.addLine(to: CGPoint(x: x, y: height))
                        path.closeSubpath()
                    }
                }
            }
            .fill(
                LinearGradient(
                    colors: [
                        color.opacity(0.35),
                        color.opacity(0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // линия
            Path { path in
                for (index, value) in data.enumerated() {
                    let x = CGFloat(index) * stepX
                    let y = height - CGFloat(value / maxValue) * height
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                LinearGradient(
                    colors: [color, color.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
            )
            .shadow(color: color.opacity(0.7), radius: 6, x: 0, y: 4)
        }
    }
}

