//
//  TaskStorage.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import Foundation

enum TaskStorage {
    private static let key = "FocusTasks"

    static func load() -> [FocusTask] {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: key) else {
            return []
        }

        do {
            let tasks = try JSONDecoder().decode([FocusTask].self, from: data)
            return tasks
        } catch {
            return []
        }
    }

    static func save(_ tasks: [FocusTask]) {
        let defaults = UserDefaults.standard
        do {
            let data = try JSONEncoder().encode(tasks)
            defaults.set(data, forKey: key)
        } catch {
            // ignore encoding errors for now
        }
    }
}

