//
//  BirthTimeInputView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

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

                summaryChips

                pickerStack
                    .padding(.horizontal, -8)
                    .padding(.top, 8)

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

    private var summaryChips: some View {
        let summary = controller.state.summaryTexts
        return HStack(spacing: 16) {
            summaryChip(text: summary.0)
            summaryChip(text: summary.1)
            summaryChip(text: summary.2)
        }
    }

    private func summaryChip(text: String) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white,
                        Color(red: 0.97, green: 0.96, blue: 0.94)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: 48)
            .overlay(
                Text(text)
                    .font(DSFonts.serifMedium(18))
                    .foregroundStyle(Color.black)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, y: 6)
    }

    private var pickerStack: some View {
        HStack(spacing: 12) {
            pickerColumn(
                values: controller.state.hours,
                selection: Binding(
                    get: { controller.state.hour },
                    set: controller.updateHour
                ),
                formatter: { "\($0)点" }
            )

            pickerColumn(
                values: controller.state.minutes,
                selection: Binding(
                    get: { controller.state.minute },
                    set: controller.updateMinute
                ),
                formatter: { String(format: "%02d分", $0) }
            )

            pickerColumn(
                values: controller.state.periods,
                selection: Binding(
                    get: { controller.state.period },
                    set: controller.updatePeriod
                ),
                formatter: { $0 == .am ? "上午" : "下午" }
            )
        }
    }

    private func pickerColumn<T: Hashable>(values: [T], selection: Binding<T>, formatter: @escaping (T) -> String) -> some View {
        VStack {
            Picker("", selection: selection) {
                ForEach(values, id: \.self) { value in
                    Text(formatter(value))
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
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, y: 6)
        )
    }
}

#Preview {
    let controller = BirthTimeInputController(
        useCase: BirthTimeInputUseCase(flowState: UserOnboardingFlowState()),
        initialValue: nil
    )
    return BirthTimeInputView(controller: controller)
}
