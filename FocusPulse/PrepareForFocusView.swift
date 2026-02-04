//
//  PrepareForFocusView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

struct PrepareForFocusView: View {
    let onBegin: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var closedMessengers = false
    @State private var phoneSilenced = false
    @State private var clearIntention = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Prepare for focus")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Close messengers and social apps", isOn: $closedMessengers)
                    Toggle("Silence notifications", isOn: $phoneSilenced)
                    Toggle("Set a clear intention for this session", isOn: $clearIntention)
                }
                .toggleStyle(SwitchToggleStyle(tint: AppTheme.focusAccent))
                .foregroundColor(.white)

                Spacer()

                Button {
                    onBegin()
                    dismiss()
                } label: {
                    Text("Begin focus session")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.focusAccent)
                        .cornerRadius(14)
                }
            }
            .padding()
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

