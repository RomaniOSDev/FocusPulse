//
//  UserPreferencesStorage.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import Foundation

enum UserPreferencesStorage {
    private static let key = "UserPreferences"

    static func load() -> UserPreferences {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: key) else {
            return UserPreferences()
        }

        do {
            let decoded = try JSONDecoder().decode(UserPreferences.self, from: data)
            return decoded
        } catch {
            return UserPreferences()
        }
    }

    static func save(_ preferences: UserPreferences) {
        let defaults = UserDefaults.standard
        do {
            let data = try JSONEncoder().encode(preferences)
            defaults.set(data, forKey: key)
        } catch {
            // ignore encoding errors for now
        }
    }
}

