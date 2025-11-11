//
//  NameEntryView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct NameEntryView: View {
    @ObservedObject var controller: NameEntryController

    init(controller: NameEntryController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            DSColors.nameEntryGradient
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {
                Button(action: controller.goBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(
                            Circle().fill(Color.white.opacity(0.15))
                        )
                }
                .buttonStyle(.plain)

                Text(DSStrings.NameEntry.title)
                    .font(DSFonts.serifMedium(34))
                    .foregroundStyle(.white)

                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(red: 1.0, green: 0.96, blue: 0.92)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color(red: 1.0, green: 0.9, blue: 0.88), lineWidth: 1)
                        )
                        .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.7).opacity(0.25), radius: 20, x: 0, y: 12)
                        .overlay(
                            HStack {
                                TextField("", text: Binding(
                                    get: { controller.state.input },
                                    set: { controller.updateInput($0) }
                                ))
                                .font(DSFonts.serifRegular(18))
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .foregroundStyle(Color(red: 0.13, green: 0.17, blue: 0.27))
                            }
                            .padding(.horizontal, 20)
                        )
                }

                Spacer()

                Button(action: controller.submit) {
                    Text(DSStrings.Common.actionContinue)
                        .font(DSFonts.serifMedium(17))
                        .foregroundStyle(Color(red: 0.13, green: 0.17, blue: 0.29))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color.white.opacity(0.98))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Color.white.opacity(0.7), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 20, y: 8)
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
    let flowState = UserOnboardingFlowState()
    flowState.name = "测试"
    let controller = NameEntryController(useCase: NameEntryUseCase(flowState: flowState))
    controller.updateInput("张三")
    return NameEntryView(controller: controller)
}
