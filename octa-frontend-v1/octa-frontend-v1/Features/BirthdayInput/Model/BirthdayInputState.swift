//
//  BirthdayInputState.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

struct BirthdayInputState {
    var year: Int
    var month: Int
    var day: Int

    let years: [Int]
    let months: [Int] = Array(1...12)

    init(currentDate: Date? = nil) {
        let calendar = Calendar.current
        let now = Date()
        let components = currentDate.flatMap { calendar.dateComponents([.year, .month, .day], from: $0) }

        let defaultYear = components?.year ?? max(1900, calendar.component(.year, from: now) - 25)
        let defaultMonth = components?.month ?? 1
        let defaultDay = components?.day ?? 1

        self.year = defaultYear
        self.month = defaultMonth
        self.day = defaultDay

        let currentYear = calendar.component(.year, from: now)
        self.years = Array(1900...currentYear)
    }

    var days: [Int] {
        guard
            let referenceDate = makeDateComponentsDate(),
            let range = Calendar.current.range(of: .day, in: .month, for: referenceDate)
        else {
            return Array(1...31)
        }
        return Array(range)
    }

    var selectedDate: Date? {
        makeDateComponentsDate()
    }

    private func makeDateComponentsDate() -> Date? {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return Calendar.current.date(from: comps)
    }
}
