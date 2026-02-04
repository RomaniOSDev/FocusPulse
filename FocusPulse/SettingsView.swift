//
//  SettingsView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Durations")) {
                    durationRow(
                        title: "Focus",
                        seconds: $viewModel.preferences.focusDuration,
                        step: 5 * 60,
                        range: 15...90
                    )
                    durationRow(
                        title: "Short Break",
                        seconds: $viewModel.preferences.shortBreakDuration,
                        step: 60,
                        range: 3...15
                    )
                    durationRow(
                        title: "Long Break",
                        seconds: $viewModel.preferences.longBreakDuration,
                        step: 60,
                        range: 15...30
                    )
                }

                Section(header: Text("Goals")) {
                    Stepper(value: $viewModel.preferences.dailySessionGoal, in: 1...24) {
                        Text("Daily sessions: \(viewModel.preferences.dailySessionGoal)")
                    }

                    Stepper(value: $viewModel.preferences.sessionsBeforeLongBreak, in: 1...8) {
                        Text("Sessions before long break: \(viewModel.preferences.sessionsBeforeLongBreak)")
                    }
                }

                Section(header: Text("Pulse Guard")) {
                    Picker("Strictness", selection: $viewModel.preferences.distractionDetectionLevel) {
                        ForEach(DistractionLevel.allCases) { level in
                            Text(level.title).tag(level)
                        }
                    }
                }

                Section(header: Text("About")) {
                    Button("Rate us") {
                        rateApp()
                    }
                    Button("Privacy Policy") {
                        openPrivacyPolicy()
                    }
                    Button("Terms of Use") {
                        openTermsOfUse()
                    }
                }
            }
            .navigationTitle("Settings")
            .onDisappear {
                viewModel.savePreferences()
            }
        }
    }

    private func durationRow(
        title: String,
        seconds: Binding<TimeInterval>,
        step: TimeInterval,
        range: ClosedRange<Int>
    ) -> some View {
        let bindingMinutes = Binding<Int>(
            get: { Int(seconds.wrappedValue / 60) },
            set: { seconds.wrappedValue = TimeInterval($0 * 60) }
        )

        return Stepper(value: bindingMinutes, in: range, step: Int(step / 60)) {
            Text("\(title): \(bindingMinutes.wrappedValue) min")
        }
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: "https://www.termsfeed.com/live/c4a314e4-8101-4814-b4ae-886fcd11dd44") {
            UIApplication.shared.open(url)
        }
    }

    private func openTermsOfUse() {
        if let url = URL(string: "https://www.termsfeed.com/live/49dbf3f8-2da4-4327-bb71-0404c472f380") {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

