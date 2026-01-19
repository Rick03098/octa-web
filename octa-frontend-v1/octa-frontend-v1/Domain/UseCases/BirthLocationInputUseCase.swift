//
//  BirthLocationInputUseCase.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

@MainActor
struct BirthLocationInputUseCase {
    let flowState: UserOnboardingFlowState

    func submit(location: String) {
        flowState.birthLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
