//
//  SessionStore.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

/// 管理當前用戶的會話狀態與 Token，後續可擴展刷新與鑑權邏輯。
@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var isAuthenticated: Bool

    init(isAuthenticated: Bool = false) {
        self.isAuthenticated = isAuthenticated
    }

    func updateAuthenticationState(_ loggedIn: Bool) {
        isAuthenticated = loggedIn
    }
}
