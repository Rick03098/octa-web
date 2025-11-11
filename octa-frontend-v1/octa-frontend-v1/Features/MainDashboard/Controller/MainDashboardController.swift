//
//  MainDashboardController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

@MainActor
final class MainDashboardController: ObservableObject {
    @Published private(set) var state: MainDashboardState

    private let flowState: UserOnboardingFlowState
    var onAddEnvironment: (() -> Void)?
    var onSelfSelected: (() -> Void)?

    init(flowState: UserOnboardingFlowState) {
        self.flowState = flowState
        self.state = MainDashboardState(
            userName: flowState.name.isEmpty ? "朋友" : flowState.name,
            greetingPeriod: Self.makeGreetingPeriod(),
            hasEnvironments: false
        )
    }

    static func makeGreetingPeriod(date: Date = Date()) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12:
            return "早上"
        case 12..<18:
            return "下午"
        default:
            return "晚上"
        }
    }

    func refreshGreeting() {
        state = MainDashboardState(
            userName: flowState.name.isEmpty ? "朋友" : flowState.name,
            greetingPeriod: Self.makeGreetingPeriod(),
            hasEnvironments: state.hasEnvironments
        )
    }

    func tapAddEnvironment() {
        onAddEnvironment?()
    }

    func tapSelfTab() {
        onSelfSelected?()
    }
}
