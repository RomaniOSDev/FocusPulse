//
//  DistractionDetector.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import Foundation
import CoreMotion

final class DistractionDetector {
    private let motionManager = CMMotionManager()
    private var lastAppSwitchTime: Date?

    func startMonitoring() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
        }
        // TODO: monitor app switches and idle time if needed
    }

    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
    }

    func calculateDistractionScore() -> Double {
        // Placeholder combined score 0.0...1.0
        return 0.0
    }
}

