//
//  MainDashboardView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

struct MainDashboardView: View {
    @ObservedObject var controller: MainDashboardController

    init(controller: MainDashboardController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            DSColors.mainEnvironmentGradient
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(DSStrings.Main.greeting(name: controller.state.userName, period: controller.state.greetingPeriod))
                        .font(DSFonts.serifMedium(28))
                        .foregroundStyle(Color(red: 0.1, green: 0.12, blue: 0.2))
                    Text(DSStrings.Main.greetingQuestion)
                        .font(DSFonts.serifRegular(17))
                        .foregroundStyle(Color(red: 0.24, green: 0.26, blue: 0.3))
                }

                Spacer()

                VStack(spacing: 12) {
                    Text(DSStrings.Main.addEnvironmentTitle)
                        .font(DSFonts.serifMedium(22))
                    Text(DSStrings.Main.addEnvironmentSubtitle)
                        .font(DSFonts.serifRegular(16))
                }
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                .background(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.96, green: 0.73, blue: 0.8),
                            Color(red: 1.0, green: 0.87, blue: 0.91),
                            Color(red: 1.0, green: 0.97, blue: 0.95)
                        ]),
                        center: .center,
                        startRadius: 60,
                        endRadius: 320
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 48, style: .continuous))
                .shadow(color: Color(red: 0.98, green: 0.67, blue: 0.74).opacity(0.35), radius: 30, y: 15)

                Spacer()

                bottomTabs
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
    }

    private var bottomTabs: some View {
        HStack(spacing: 16) {
            DashboardTabButton(
                title: DSStrings.Main.tabEnvironment,
                systemImage: "circle.grid.2x2",
                isActive: true,
                action: {}
            )

            DashboardTabButton(
                title: DSStrings.Main.tabSelf,
                systemImage: "person.crop.square",
                isActive: false,
                action: { controller.tapSelfTab() }
            )

            Button(action: controller.tapAddEnvironment) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color(red: 0.17, green: 0.2, blue: 0.32))
                    .frame(width: 58, height: 58)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.12), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    let controller = MainDashboardController(flowState: UserOnboardingFlowState())
    return MainDashboardView(controller: controller)
}
