//
//  SelfCenterController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

@MainActor
final class SelfCenterController: ObservableObject {
    @Published private(set) var sections: [[SelfCenterItem]] = []

    var onEnvironmentTab: (() -> Void)?
    var onLogout: (() -> Void)?

    init() {
        sections = [
            [
                SelfCenterItem(title: DSStrings.SelfCenter.sectionProfile, iconName: "person", kind: .profile),
                SelfCenterItem(title: DSStrings.SelfCenter.sectionReminder, iconName: "bell", kind: .reminder),
                SelfCenterItem(title: DSStrings.SelfCenter.sectionLanguage, iconName: "globe", kind: .language)
            ],
            [
                SelfCenterItem(title: DSStrings.SelfCenter.sectionTerms, iconName: "doc.plaintext", kind: .terms),
                SelfCenterItem(title: DSStrings.SelfCenter.sectionPrivacy, iconName: "hand.raised", kind: .privacy),
                SelfCenterItem(title: DSStrings.SelfCenter.sectionSubscription, iconName: "creditcard", kind: .subscription),
                SelfCenterItem(title: DSStrings.SelfCenter.sectionAbout, iconName: "info.circle", kind: .about)
            ],
            [
                SelfCenterItem(title: DSStrings.SelfCenter.logout, iconName: "arrow.uturn.backward", kind: .logout)
            ]
        ]
    }

    func select(item: SelfCenterItem) {
        if item.kind == .logout {
            onLogout?()
        }
        // 其余项目前为占位
    }

    func switchToEnvironment() {
        onEnvironmentTab?()
    }
}
