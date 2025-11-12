//
//  BirthTimeInputView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

struct BirthTimeInputView: View {
    @ObservedObject var controller: BirthTimeInputController

    init(controller: BirthTimeInputController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.97, blue: 0.94),
                    Color(red: 0.80, green: 0.91, blue: 1.0),
                    Color(red: 0.97, green: 0.94, blue: 0.89)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.83, green: 0.94, blue: 1.0),
                            Color(red: 0.99, green: 0.97, blue: 0.93).opacity(0)
                        ]),
                        center: .center,
                        startRadius: 40,
                        endRadius: 400
                    )
                )
                .scaleEffect(1.2)
                .offset(y: -120)
                .blur(radius: 40)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 32) {
                Button(action: controller.goBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(Circle().fill(Color.white.opacity(0.15)))
                }
                .buttonStyle(.plain)

                Text(DSStrings.BirthTime.title)
                    .font(DSFonts.serifMedium(36))
                    .foregroundStyle(Color.white)
                    .lineSpacing(8)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, y: 6)

                pickerStack
                    .padding(.top, 8)
                    .overlay(alignment: .center) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white.opacity(0.12))
                            )
                            .frame(height: BirthTimePickerLayout.highlightHeight)
                    }

                Text(DSStrings.BirthTime.hint)
                    .font(DSFonts.serifRegular(13))
                    .foregroundStyle(Color.white.opacity(0.7))

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
            let spacing = BirthTimePickerLayout.columnSpacing
            let availableWidth = max(0, geo.size.width - spacing * 2)
            let hourWidth = availableWidth * BirthTimePickerLayout.hourWidthRatio
            let minuteWidth = availableWidth * BirthTimePickerLayout.minuteWidthRatio
            let periodWidth = availableWidth * BirthTimePickerLayout.periodWidthRatio

            HStack(spacing: spacing) {
                pickerColumn(
                    values: controller.state.hours,
                    selection: Binding(
                        get: { controller.state.hour },
                        set: controller.updateHour
                    ),
                    formatter: { "\($0)点" }
                )
                .frame(width: hourWidth)

                pickerColumn(
                    values: controller.state.minutes,
                    selection: Binding(
                        get: { controller.state.minute },
                        set: controller.updateMinute
                    ),
                    formatter: { String(format: "%02d分", $0) }
                )
                .frame(width: minuteWidth)

                pickerColumn(
                    values: controller.state.periods,
                    selection: Binding(
                        get: { controller.state.period },
                        set: controller.updatePeriod
                    ),
                    formatter: { $0 == .am ? "上午" : "下午" }
                )
                .frame(width: periodWidth)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        .frame(height: BirthTimePickerLayout.pickerHeight)
    }

    private func pickerColumn<T: Hashable>(values: [T], selection: Binding<T>, formatter: @escaping (T) -> String) -> some View {
        Picker("", selection: selection) {
            ForEach(values, id: \.self) { value in
                Text(formatter(value))
                    .font(DSFonts.serifRegular(18))
                    .foregroundStyle(Color.black)
            }
        }
        .labelsHidden()
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
        .frame(height: BirthTimePickerLayout.pickerHeight)
        .clipped()
    }
}

private enum BirthTimePickerLayout {
    static let columnSpacing: CGFloat = 12
    static let pickerHeight: CGFloat = 200
    static let highlightHeight: CGFloat = 56
    static let hourWidthRatio: CGFloat = 0.4
    static let minuteWidthRatio: CGFloat = 0.4
    static let periodWidthRatio: CGFloat = 0.2
}

#Preview {
    let controller = BirthTimeInputController(
        useCase: BirthTimeInputUseCase(flowState: UserOnboardingFlowState()),
        initialValue: nil
    )
    return BirthTimeInputView(controller: controller)
}
