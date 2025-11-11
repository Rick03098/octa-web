//
//  BirthdayInputView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct BirthdayInputView: View {
    @ObservedObject var controller: BirthdayInputController

    init(controller: BirthdayInputController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            DSColors.birthdayGradient
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

                Text(DSStrings.Birthday.title)
                    .font(DSFonts.serifMedium(34))
                    .foregroundStyle(.white)

                pickerStack
                    .padding(.horizontal, -8)
                    .padding(.top, 8)
                    .overlay(alignment: .center) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 52)
                    }

                Spacer()

                Button(action: controller.submit) {
                    Text(DSStrings.Common.actionContinue)
                        .font(DSFonts.serifMedium(17))
                        .foregroundStyle(Color(red: 0.99, green: 0.43, blue: 0.47))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color.white)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
    }

    private var pickerStack: some View {
        HStack(spacing: 12) {
            pickerColumn(
                values: controller.state.years,
                selection: Binding(
                    get: { controller.state.year },
                    set: controller.updateYear
                ),
                labelSuffix: "年"
            )

            pickerColumn(
                values: controller.state.months,
                selection: Binding(
                    get: { controller.state.month },
                    set: controller.updateMonth
                ),
                labelSuffix: "月"
            )

            pickerColumn(
                values: controller.state.days,
                selection: Binding(
                    get: { controller.state.day },
                    set: controller.updateDay
                ),
                labelSuffix: "日"
            )
        }
    }

    private func pickerColumn(values: [Int], selection: Binding<Int>, labelSuffix: String) -> some View {
        VStack {
            Picker("", selection: selection) {
                ForEach(values, id: \.self) { value in
                    Text("\(value)\(labelSuffix)")
                        .font(DSFonts.serifRegular(18))
                        .foregroundStyle(Color.black)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .clipped()
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.8))
        )
    }
}

#Preview {
    let controller = BirthdayInputController(
        useCase: BirthdayInputUseCase(flowState: UserOnboardingFlowState()),
        initialDate: Date()
    )
    return BirthdayInputView(controller: controller)
}
