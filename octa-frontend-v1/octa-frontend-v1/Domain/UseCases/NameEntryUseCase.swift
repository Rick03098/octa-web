//
//  NameEntryUseCase.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

/// 專責處理名字信息頁的業務邏輯。
struct NameEntryUseCase {
    let flowState: UserOnboardingFlowState

    func submit(name: String) {
        flowState.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
