//
//  BirthTimeInputState.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

struct BirthTimeInputState {
    var hour: Int
    var minute: Int
    var period: DayPeriod

    let hours: [Int] = Array(1...12)
    let minutes: [Int] = Array(0...59)
    let periods: [DayPeriod] = DayPeriod.allCases

    init(value: BirthTimeValue?) {
        if let value {
            hour = value.hour
            minute = value.minute
            period = value.period
        } else {
            hour = 12
            minute = 0
            period = .pm
        }
    }

    var summaryTexts: (String, String, String) {
        (
            "\\(hour)点",
            String(format: "%02d分", minute),
            period == .am ? "上午" : "下午"
        )
    }

    var selectedValue: BirthTimeValue {
        BirthTimeValue(hour: hour, minute: minute, period: period)
    }
}
