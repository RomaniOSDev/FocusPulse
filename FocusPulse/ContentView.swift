//
//  ContentView.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sessionViewModel = SessionViewModel()
    @StateObject private var statisticsViewModel = StatisticsViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var selectedTab: Int = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showOnboarding: Bool = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(sessionViewModel: sessionViewModel,
                     statisticsViewModel: statisticsViewModel,
                     onStartFocus: {
                         selectedTab = 1
                         sessionViewModel.startDefaultFocus()
                     })
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            FocusSessionView(viewModel: sessionViewModel)
                .tabItem {
                    Image(systemName: "timer")
                    Text("Focus")
                }
                .tag(1)

            StatisticsRootView(viewModel: statisticsViewModel)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }
                .tag(2)

            SettingsView(viewModel: settingsViewModel)
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text("Settings")
                }
                .tag(3)
        }
        .tint(AppTheme.focusAccent)
        .onAppear {
            if !hasSeenOnboarding {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                hasSeenOnboarding = true
                showOnboarding = false
            }
        }
    }
}

