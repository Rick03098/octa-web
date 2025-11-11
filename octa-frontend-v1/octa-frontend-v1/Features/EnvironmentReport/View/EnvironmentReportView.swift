//
//  EnvironmentReportView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct EnvironmentReportView: View {
    @ObservedObject var controller: EnvironmentReportController

    init(controller: EnvironmentReportController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            DSColors.reportGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    ForEach(controller.report.sections) { section in
                        reportSection(section)
                    }

                    moreQuestions
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: controller.goBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black)
                        .padding(8)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.black.opacity(0.7))
                        .padding(8)
                }
                .buttonStyle(.plain)
                .disabled(true)
            }

            Text(controller.report.title)
                .font(DSFonts.serifMedium(28))
                .foregroundStyle(.black)

            Text(controller.report.subtitle)
                .font(DSFonts.serifRegular(16))
                .foregroundStyle(.black.opacity(0.7))
        }
        .padding(.top, 16)
    }

    private func reportSection(_ section: EnvironmentReportSection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.title)
                .font(DSFonts.serifMedium(18))
                .foregroundStyle(Color(red: 0.15, green: 0.2, blue: 0.32))
            Text(section.body)
                .font(DSFonts.serifRegular(16))
                .foregroundStyle(Color(red: 0.16, green: 0.18, blue: 0.26))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 15, y: 8)
        )
    }

    private var moreQuestions: some View {
        VStack(spacing: 16) {
            Text(DSStrings.Report.moreQuestions)
                .font(DSFonts.serifRegular(16))
                .foregroundStyle(Color(red: 0.2, green: 0.24, blue: 0.36))

            Button(action: controller.openChat) {
                Text(DSStrings.Report.actionChat)
                    .font(DSFonts.serifMedium(17))
                    .foregroundStyle(Color(red: 0.13, green: 0.17, blue: 0.29))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.white)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 12)
    }
}

#Preview {
    let controller = EnvironmentReportController(useCase: EnvironmentReportUseCase(backendStatus: .notConnected))
    return EnvironmentReportView(controller: controller)
}
