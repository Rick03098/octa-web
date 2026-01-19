//
//  OrientationMonitor.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation
import CoreMotion

final class OrientationMonitor {
    private let motionManager = CMMotionManager()
    private var baseline: Double?
    private var stableStart: Date?
    private var completion: ((Double) -> Void)?
    private var currentAngleHandler: ((Double, Double) -> Void)?
    private let threshold: Double = 5 // degrees
    private let requiredDuration: TimeInterval = 3

    func start(onAngleUpdate: @escaping (Double, Double) -> Void, completion: @escaping (Double) -> Void) {
        stop()
        // 模拟器或不支持设备姿态的环境下，CoreMotion 不可用，直接返回默认角度，避免界面卡死
        if !motionManager.isDeviceMotionAvailable {
            onAngleUpdate(0, 1)
            completion(0)
            return
        }
        self.currentAngleHandler = onAngleUpdate
        self.completion = completion
        baseline = nil
        stableStart = nil

        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            self.processMotion(motion)
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        completion = nil
        currentAngleHandler = nil
        baseline = nil
        stableStart = nil
    }

    private func processMotion(_ motion: CMDeviceMotion) {
        let yaw = motion.attitude.yaw
        let angle = normalizedDegrees(from: yaw)

        if baseline == nil {
            baseline = angle
        }

        let delta = angleDifference(angle, baseline ?? angle)

        if delta <= threshold {
            if stableStart == nil {
                stableStart = Date()
            }
            let progress = min(max(Date().timeIntervalSince(stableStart!) / requiredDuration, 0), 1)
            currentAngleHandler?(angle, progress)
            if progress >= 1, let baseline {
                completion?(baseline)
                stop()
            }
        } else {
            baseline = angle
            stableStart = nil
            currentAngleHandler?(angle, 0)
        }
    }

    private func normalizedDegrees(from radians: Double) -> Double {
        var degrees = radians * 180 / .pi
        if degrees < 0 { degrees += 360 }
        return degrees
    }

    private func angleDifference(_ a: Double, _ b: Double) -> Double {
        var diff = abs(a - b)
        if diff > 180 { diff = 360 - diff }
        return diff
    }
}
