//
//  BirthdayInputView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

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
                    .padding(.top, 8)
                    .overlay(alignment: .center) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white.opacity(0.1))
                            )
                            .frame(height: BirthdayPickerLayout.highlightHeight)
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
        GeometryReader { geo in
            let spacing = BirthdayPickerLayout.columnSpacing
            let availableWidth = max(0, geo.size.width - spacing * 2)
            let yearWidth = availableWidth * BirthdayPickerLayout.yearWidthRatio
            let monthDayWidth = availableWidth * BirthdayPickerLayout.monthDayWidthRatio

            HStack(spacing: spacing) {
                pickerColumn(
                    values: controller.state.years,
                    selection: Binding(
                        get: { controller.state.year },
                        set: controller.updateYear
                    ),
                    labelSuffix: "年"
                )
                .frame(width: yearWidth)

                pickerColumn(
                    values: controller.state.months,
                    selection: Binding(
                        get: { controller.state.month },
                        set: controller.updateMonth
                    ),
                    labelSuffix: "月"
                )
                .frame(width: monthDayWidth)

                pickerColumn(
                    values: controller.state.days,
                    selection: Binding(
                        get: { controller.state.day },
                        set: controller.updateDay
                    ),
                    labelSuffix: "日"
                )
                .frame(width: monthDayWidth)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        .frame(height: BirthdayPickerLayout.pickerHeight)
    }

    private func pickerColumn(values: [Int], selection: Binding<Int>, labelSuffix: String) -> some View {
        Picker("", selection: selection) {
            ForEach(values, id: \.self) { value in
                Text("\(value)\(labelSuffix)")
                    .font(DSFonts.serifRegular(18))
                    .foregroundStyle(Color.black)
            }
        }
        .labelsHidden()
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
        .frame(height: BirthdayPickerLayout.pickerHeight)
        .clipped()
    }
}

private enum BirthdayPickerLayout {
    static let columnSpacing: CGFloat = 12
    static let yearWidthRatio: CGFloat = 0.44
    static let monthDayWidthRatio: CGFloat = (1 - yearWidthRatio) / 2
    static let pickerHeight: CGFloat = 200
    static let highlightHeight: CGFloat = 56
}

#Preview {
    let controller = BirthdayInputController(
        useCase: BirthdayInputUseCase(flowState: UserOnboardingFlowState()),
        initialDate: Date()
    )
    return BirthdayInputView(controller: controller)
}
