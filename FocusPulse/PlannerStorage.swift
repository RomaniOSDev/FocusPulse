//
//  PlannerStorage.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import Foundation

enum PlannerStorage {
    private static let key = "FocusPlannerBlocks"

    static func load() -> [FocusPlanBlock] {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: key) else {
            return []
        }

        do {
            let blocks = try JSONDecoder().decode([FocusPlanBlock].self, from: data)
            return blocks
        } catch {
            return []
        }
    }

    static func save(_ blocks: [FocusPlanBlock]) {
        let defaults = UserDefaults.standard
        do {
            let data = try JSONEncoder().encode(blocks)
            defaults.set(data, forKey: key)
        } catch {
            // ignore
        }
    }
}

