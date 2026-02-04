//
//  CalendarIntegrationService.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import Foundation
import EventKit

final class CalendarIntegrationService {
    private let eventStore = EKEventStore()

    func requestAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func fetchFocusEvents(for date: Date) -> [EKEvent] {
        let calendars = eventStore.calendars(for: .event)
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: calendars)
        let events = eventStore.events(matching: predicate)
        // Простая эвристика: события, содержащие "focus" в названии
        return events.filter { $0.title.lowercased().contains("focus") }
    }
}

