//
//  BirthLocationInputView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct BirthLocationInputView: View {
    @ObservedObject var controller: BirthLocationInputController

    init(controller: BirthLocationInputController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            DSColors.birthLocationGradient
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

                Text(DSStrings.BirthLocation.title)
                    .font(DSFonts.serifMedium(34))
                    .foregroundStyle(.white)

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(height: 56)
                    .overlay(
                        TextField("", text: Binding(
                            get: { controller.state.input },
                            set: { controller.updateInput($0) }
                        ))
                        .font(DSFonts.serifRegular(18))
                        .textInputAutocapitalization(.words)
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 20)
                    )

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
}

#Preview {
    let controller = BirthLocationInputController(
        useCase: BirthLocationInputUseCase(flowState: UserOnboardingFlowState()),
        initialValue: ""
    )
    return BirthLocationInputView(controller: controller)
}
