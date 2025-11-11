//
//  LoginController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

@MainActor
final class LoginController: ObservableObject {
    @Published private(set) var state = LoginState()

    var backendStatus: BackendConnectionStatus = .notConnected
    var onCreateAccount: (() -> Void)?
    var onGoogleLogin: (() -> Void)?
    var onMemberLogin: (() -> Void)?

    func handleCreateAccount() {
        guard backendStatus == .connected else {
            onCreateAccount?()
            return
        }
        // TODO: 調用後端註冊 API
    }

    func handleGoogleLogin() {
        guard backendStatus == .connected else {
            onGoogleLogin?()
            return
        }
        // TODO: 調用 Google OAuth 登入
    }

    func handleMemberLogin() {
        guard backendStatus == .connected else {
            onMemberLogin?()
            return
        }
        // TODO: 調用會員登入流程
    }
}
