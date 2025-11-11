//
//  GenderSelectionUseCase.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

struct GenderSelectionUseCase {
    let flowState: UserOnboardingFlowState

    func submit(gender: UserGender) {
        flowState.gender = gender
    }
}
