//
//  BirthTimeInputUseCase.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

@MainActor
struct BirthTimeInputUseCase {
    let flowState: UserOnboardingFlowState

    func submit(time: BirthTimeValue) {
        flowState.birthTime = time
    }
}
