//
//  BaziResultController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

@MainActor
final class BaziResultController: ObservableObject {
    @Published private(set) var pages: [BaziResultPage] = []
    @Published var currentIndex: Int = 0
    @Published var showDots: Bool = true

    private let useCase: BaziResultUseCase
    private let flowState: UserOnboardingFlowState
    var onContinue: (() -> Void)?
    var onBack: (() -> Void)?

    init(useCase: BaziResultUseCase, flowState: UserOnboardingFlowState) {
        self.useCase = useCase
        self.flowState = flowState
        loadPages()
    }

    func loadPages() {
        pages = useCase.loadPages(flowState: flowState)
    }

    func updatePage(index: Int) {
        guard pages.indices.contains(index) else { return }
        currentIndex = index
        if index == pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.6)) {
                showDots = false
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                showDots = true
            }
        }
    }

    func goBack() {
        onBack?()
    }

    func continueAction() {
        onContinue?()
    }
}
