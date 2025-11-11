//
//  EnvironmentPreviewView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

struct EnvironmentPreviewView: View {
    @ObservedObject var controller: EnvironmentPreviewController

    init(controller: EnvironmentPreviewController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            DSColors.mainEnvironmentGradient
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer().frame(height: 60)

                previewCard(
                    title: DSStrings.Preview.titleSpring,
                    subtitle: DSStrings.Preview.subtitleSpring,
                    color: Color(red: 0.99, green: 0.79, blue: 0.83)
                )

                previewCard(
                    title: DSStrings.Preview.titleLight,
                    subtitle: DSStrings.Preview.subtitleLight,
                    color: Color(red: 0.92, green: 0.88, blue: 0.95)
                )

                previewCard(
                    title: DSStrings.Preview.titleWander,
                    subtitle: DSStrings.Preview.subtitleLight,
                    color: Color(red: 0.85, green: 0.92, blue: 0.95)
                )

                Spacer()

                Button(action: controller.continueFlow) {
                    Text(DSStrings.Preview.actionOpen)
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
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
    }

    private func previewCard(title: String, subtitle: String, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 36, style: .continuous)
            .fill(color.opacity(0.85))
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .overlay(
                VStack(spacing: 6) {
                    Text(title)
                        .font(DSFonts.serifMedium(20))
                    Text(subtitle)
                        .font(DSFonts.serifRegular(15))
                }
                .foregroundStyle(Color.white)
            )
            .shadow(color: color.opacity(0.4), radius: 20, y: 10)
    }
}

#Preview {
    EnvironmentPreviewView(controller: EnvironmentPreviewController())
}
