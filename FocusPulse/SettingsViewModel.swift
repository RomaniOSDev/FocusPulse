//
//  SettingsViewModel.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var preferences: UserPreferences
    @Published var isPremium: Bool = false

    init(preferences: UserPreferences = UserPreferences()) {
        // load saved preferences if available
        self.preferences = UserPreferencesStorage.load()
    }

    func savePreferences() {
        UserPreferencesStorage.save(preferences)
    }

    func restorePurchases() {
        // TODO: integrate StoreKit
    }
}

