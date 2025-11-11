//
//  BirthdayInputController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

@MainActor
final class BirthdayInputController: ObservableObject {
    @Published private(set) var state: BirthdayInputState

    private let useCase: BirthdayInputUseCase
    var onContinue: (() -> Void)?
    var onBack: (() -> Void)?

    init(useCase: BirthdayInputUseCase, initialDate: Date? = nil) {
        self.useCase = useCase
        self.state = BirthdayInputState(currentDate: initialDate)
    }

    func updateYear(_ value: Int) {
        state.year = value
        clampDay()
    }

    func updateMonth(_ value: Int) {
        state.month = value
        clampDay()
    }

    func updateDay(_ value: Int) {
        state.day = value
        clampDay()
    }

    private func clampDay() {
        let maxDay = state.days.max() ?? 31
        if state.day > maxDay {
            state.day = maxDay
        }
    }

    func submit() {
        guard let date = state.selectedDate else { return }
        useCase.submit(date: date)
        onContinue?()
    }

    func goBack() {
        onBack?()
    }
}
