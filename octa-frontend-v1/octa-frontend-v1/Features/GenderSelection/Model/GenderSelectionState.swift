//
//  GenderSelectionState.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

struct GenderSelectionState {
    var selectedGender: UserGender?
    let options: [UserGender] = UserGender.allCases

    var isValid: Bool {
        selectedGender != nil
    }
}
