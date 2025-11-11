//
//  octa_frontend_v1App.swift
//  octa-frontend-v1
//
//  Created by davidzhou on 2025/11/5.
//

import SwiftUI

@main
struct octa_frontend_v1App: App {
    @StateObject private var sessionStore: SessionStore
    @StateObject private var onboardingFlow: UserOnboardingFlowState
    @StateObject private var coordinator: AppCoordinator

    init() {
        let sessionStore = SessionStore()
        let flowState = UserOnboardingFlowState()
        FontRegistrar.registerFontsIfNeeded()
        _sessionStore = StateObject(wrappedValue: sessionStore)
        _onboardingFlow = StateObject(wrappedValue: flowState)
        _coordinator = StateObject(
            wrappedValue: AppCoordinator(
                sessionStore: sessionStore,
                onboardingFlow: flowState,
                backendStatus: .notConnected
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            CoordinatorRootView(coordinator: coordinator)
        }
    }
}

private struct CoordinatorRootView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        coordinator.makeRootView()
    }
}
