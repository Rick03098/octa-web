//
//  GenderSelectionView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct GenderSelectionView: View {
    @ObservedObject var controller: GenderSelectionController

    init(controller: GenderSelectionController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            DSColors.genderGradient
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {
                Button(action: controller.goBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(Circle().fill(Color.white.opacity(0.15)))
                }
                .buttonStyle(.plain)

                Text(DSStrings.Gender.title)
                    .font(DSFonts.serifMedium(34))
                    .foregroundStyle(.white)

                VStack(spacing: 16) {
                    ForEach(controller.state.options, id: \.self) { option in
                        genderButton(option: option)
                    }
                }

                Text(DSStrings.Gender.info)
                    .font(DSFonts.serifRegular(13))
                    .foregroundStyle(Color.white.opacity(0.7))

                Spacer()

                Button(action: controller.submit) {
                    Text(DSStrings.Common.actionContinue)
                        .font(DSFonts.serifMedium(17))
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color.white.opacity(controller.state.isValid ? 1 : 0.6))
                        )
                }
                .disabled(!controller.state.isValid)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
    }

    private func genderButton(option: UserGender) -> some View {
        let isSelected = controller.state.selectedGender == option
        return Button {
            controller.select(option)
        } label: {
            Text(option.rawValue)
                .font(DSFonts.serifMedium(18))
                .foregroundStyle(isSelected ? Color(red: 0.99, green: 0.43, blue: 0.47) : Color.black.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0.05), radius: isSelected ? 10 : 4, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(isSelected ? Color(red: 0.99, green: 0.43, blue: 0.47) : Color.clear, lineWidth: 2)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let controller = GenderSelectionController(
        useCase: GenderSelectionUseCase(flowState: UserOnboardingFlowState()),
        initial: nil
    )
    return GenderSelectionView(controller: controller)
}
