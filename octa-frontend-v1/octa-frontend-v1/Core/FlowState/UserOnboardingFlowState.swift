//
//  UserOnboardingFlowState.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

/// 保存用戶在 13 步流程中的輸入，避免在多頁切換時流失。
@MainActor
final class UserOnboardingFlowState: ObservableObject {
    @Published var name: String = ""
    @Published var birthDate: Date?
    @Published var birthTime: BirthTimeValue?
    @Published var birthLocation: String = ""
    @Published var gender: UserGender?
    @Published var orientationDegrees: Double?

    func reset() {
        name = ""
        birthDate = nil
        birthTime = nil
        birthLocation = ""
        gender = nil
        orientationDegrees = nil
    }
}

struct BirthTimeValue {
    var hour: Int  // 1...12
    var minute: Int  // 0...59
    var period: DayPeriod

    var hour24: Int {
        let normalizedHour = hour % 12
        switch period {
        case .am:
            return normalizedHour
        case .pm:
            return normalizedHour + 12
        }
    }

    func toDateComponents() -> DateComponents {
        DateComponents(hour: hour24, minute: minute)
    }
}

extension UserOnboardingFlowState {
    /// 根據目前的出生日期與時間輸出 24 小時制字串，用於後端 Bazi API。
    var birthTimeString24: String? {
        guard let time = birthTime else { return nil }
        let hour = time.hour24
        let minute = time.minute
        return String(format: "%02d:%02d", hour, minute)
    }

    /// 回傳完整的 Date 物件（若已填出生日期），方便後續轉成 ISO8601。
    func resolvedBirthDateTime() -> Date? {
        guard let date = birthDate else { return nil }
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        if let time = birthTime {
            comps.hour = time.hour24
            comps.minute = time.minute
        }
        return Calendar.current.date(from: comps)
    }
}

enum DayPeriod: String, CaseIterable {
    case am = "上午"
    case pm = "下午"
}

enum UserGender: String, CaseIterable {
    case male = "男性"
    case female = "女性"
}
