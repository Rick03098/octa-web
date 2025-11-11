//
//  NameEntryState.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

struct NameEntryState {
    var input: String = ""

    var isValid: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
