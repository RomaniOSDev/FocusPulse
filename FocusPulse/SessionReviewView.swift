//
//  SessionReviewView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

struct SessionReviewView: View {
    let onDone: (Int) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var rating: Int = 4

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                Text("How focused were you?")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { value in
                        Button {
                            rating = value
                        } label: {
                            Text("\(value)")
                                .font(.headline)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(value == rating ? AppTheme.focusAccent : Color.white.opacity(0.1))
                                )
                                .foregroundColor(.white)
                        }
                    }
                }

                Spacer()

                Button {
                    onDone(rating)
                    dismiss()
                } label: {
                    Text("Save review")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.breakAccent)
                        .cornerRadius(14)
                }
            }
            .padding()
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") { dismiss() }
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
}

