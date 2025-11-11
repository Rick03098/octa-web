//
//  BirthTimeInputController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

@MainActor
final class BirthTimeInputController: ObservableObject {
    @Published private(set) var state: BirthTimeInputState

    private let useCase: BirthTimeInputUseCase
    var onContinue: (() -> Void)?
    var onBack: (() -> Void)?

    init(useCase: BirthTimeInputUseCase, initialValue: BirthTimeValue?) {
        self.useCase = useCase
        self.state = BirthTimeInputState(value: initialValue)
    }

    func updateHour(_ value: Int) {
        state.hour = value
    }

    func updateMinute(_ value: Int) {
        state.minute = value
    }

    func updatePeriod(_ value: DayPeriod) {
        state.period = value
    }

    func submit() {
        useCase.submit(time: state.selectedValue)
        onContinue?()
    }

    func goBack() {
        onBack?()
    }
}
