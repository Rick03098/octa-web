//
//  BaziResultView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct BaziResultView: View {
    @ObservedObject var controller: BaziResultController

    init(controller: BaziResultController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            TabView(selection: Binding(
                get: { controller.currentIndex },
                set: { controller.updatePage(index: $0) }
            )) {
                ForEach(Array(controller.pages.enumerated()), id: \.offset) { index, page in
                    resultPage(page)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            VStack {
                HStack {
                    Button(action: controller.goBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.7))
                            .padding(12)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                if controller.showDots {
                    pageIndicator
                        .transition(.opacity)
                        .padding(.bottom, 32)
                } else {
                    continueButton
                        .transition(.opacity)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }
            }
        }
    }

    private func resultPage(_ page: BaziResultPage) -> some View {
        LinearGradient(
            colors: page.gradient,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay(
            VStack(alignment: .leading, spacing: 16) {
                Spacer().frame(height: 120)

                Text(page.title)
                    .font(DSFonts.serifMedium(20))
                    .foregroundStyle(Color(red: 0.16, green: 0.23, blue: 0.37))

                Text(page.detail)
                    .font(DSFonts.serifRegular(20))
                    .foregroundStyle(Color(red: 0.09, green: 0.16, blue: 0.29))
                    .lineSpacing(6)

                Spacer()
            }
            .padding(.horizontal, 28)
        )
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(Array(controller.pages.indices), id: \.self) { index in
                Circle()
                    .fill(index == controller.currentIndex ? Color.black : Color.white)
                    .frame(width: 8, height: 8)
                    .opacity(index == controller.currentIndex ? 1 : 0.6)
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var continueButton: some View {
        Button(action: controller.continueAction) {
            Text("继续")
                .font(DSFonts.serifMedium(17))
                .foregroundStyle(Color(red: 0.13, green: 0.17, blue: 0.29))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white.opacity(0.95))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let controller = BaziResultController(
        useCase: BaziResultUseCase(backendStatus: .notConnected),
        flowState: UserOnboardingFlowState()
    )
    return BaziResultView(controller: controller)
}
