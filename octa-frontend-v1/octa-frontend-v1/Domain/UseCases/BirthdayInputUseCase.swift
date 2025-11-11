//
//  BirthdayInputUseCase.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

/// 處理生日輸入的寫入行為。
struct BirthdayInputUseCase {
    let flowState: UserOnboardingFlowState

    func submit(date: Date) {
        flowState.birthDate = date
    }
}
