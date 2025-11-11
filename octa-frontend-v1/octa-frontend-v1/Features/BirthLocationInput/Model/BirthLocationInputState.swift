//
//  BirthLocationInputState.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

struct BirthLocationInputState {
    var input: String

    init(initial: String) {
        input = initial
    }

    var isValid: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
