//
//  SessionHistoryStorage.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import Foundation

enum SessionHistoryStorage {
    private static let key = "FocusSessionsHistory"

    static func loadAll() -> [FocusSession] {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: key) else {
            return []
        }

        do {
            let sessions = try JSONDecoder().decode([FocusSession].self, from: data)
            return sessions
        } catch {
            return []
        }
    }

    static func append(_ session: FocusSession) {
        var all = loadAll()
        all.append(session)
        save(all)
    }

    static func save(_ sessions: [FocusSession]) {
        let defaults = UserDefaults.standard
        do {
            let data = try JSONEncoder().encode(sessions)
            defaults.set(data, forKey: key)
        } catch {
            // ignore encoding errors for now
        }
    }
}

