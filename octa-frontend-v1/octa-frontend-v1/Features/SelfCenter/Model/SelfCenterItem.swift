//
//  SelfCenterItem.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

struct SelfCenterItem: Identifiable {
    enum Kind {
        case profile
        case reminder
        case language
        case terms
        case privacy
        case subscription
        case about
        case logout
    }

    let id = UUID()
    let title: String
    let iconName: String
    let kind: Kind
}
