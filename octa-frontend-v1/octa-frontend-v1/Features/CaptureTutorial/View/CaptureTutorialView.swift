//
//  CaptureTutorialView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct CaptureTutorialView: View {
    @ObservedObject var controller: CaptureTutorialController

    init(controller: CaptureTutorialController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            DSColors.permissionsGradient
                .ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Button(action: controller.goBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.27))
                            .padding(12)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }

            Spacer()

                tutorialCard

                VStack(alignment: .leading, spacing: 8) {
                    Text(DSStrings.Tutorial.title)
                        .font(DSFonts.serifMedium(22))
                        .foregroundStyle(Color(red: 0.15, green: 0.18, blue: 0.3))

                    VStack(alignment: .leading, spacing: 6) {
                        Text("• \(DSStrings.Tutorial.bullet1)")
                        Text("• \(DSStrings.Tutorial.bullet2)")
                        Text("• \(DSStrings.Tutorial.bullet3)")
                    }
                    .font(DSFonts.serifRegular(16))
                    .foregroundStyle(Color(red: 0.24, green: 0.26, blue: 0.32))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Button(action: controller.continueFlow) {
                    Text(DSStrings.Common.actionContinue)
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
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
    }

    private var tutorialCard: some View {
        VStack {
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(Color.white)
                .frame(width: 220, height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.7), lineWidth: 4)
                        .padding(24)
                )
                .shadow(color: Color(red: 0.97, green: 0.76, blue: 0.8).opacity(0.5), radius: 30, y: 16)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    CaptureTutorialView(controller: CaptureTutorialController())
}
