//
//  SelfCenterView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct SelfCenterView: View {
    @ObservedObject var controller: SelfCenterController

    init(controller: SelfCenterController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            DSColors.selfCenterGradient
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                tabHeader

                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(controller.sections.indices, id: \.self) { sectionIndex in
                            sectionView(items: controller.sections[sectionIndex], isPrimary: sectionIndex == 0)
                        }
                    }
                    .padding(.horizontal, 8)
                }

                bottomTabs
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
    }

    private var tabHeader: some View {
        HStack(spacing: 12) {
            Text(DSStrings.SelfCenter.tabFavorites)
                .font(DSFonts.serifRegular(18))
                .opacity(0.4)
            Text(DSStrings.SelfCenter.tabSelf)
                .font(DSFonts.serifMedium(20))
            Text(DSStrings.SelfCenter.tabSettings)
                .font(DSFonts.serifRegular(18))
                .opacity(0.4)
        }
        .foregroundStyle(Color(red: 0.21, green: 0.21, blue: 0.3))
    }

    private func sectionView(items: [SelfCenterItem], isPrimary: Bool) -> some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                Button {
                    controller.select(item: item)
                } label: {
                    HStack {
                        Label(item.title, systemImage: item.iconName)
                            .labelStyle(.titleAndIcon)
                            .font(DSFonts.serifRegular(16))
                            .foregroundStyle(Color(red: 0.22, green: 0.23, blue: 0.32))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.65))
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)

                if item.id != items.last?.id {
                    Divider()
                        .padding(.leading, 18)
                        .opacity(0.4)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(isPrimary ? 0.92 : 0.9))
                .shadow(color: Color.black.opacity(0.08), radius: 20, y: 10)
        )
    }

    private var bottomTabs: some View {
        HStack(spacing: 16) {
            DashboardTabButton(
                title: DSStrings.Main.tabEnvironment,
                systemImage: "circle.grid.2x2",
                isActive: false,
                action: controller.switchToEnvironment
            )

            DashboardTabButton(
                title: DSStrings.Main.tabSelf,
                systemImage: "person.crop.square",
                isActive: true,
                action: {}
            )

            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color(red: 0.17, green: 0.2, blue: 0.32))
                    .frame(width: 58, height: 58)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.12), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
            .disabled(true)
        }
    }
}

#Preview {
    let controller = SelfCenterController()
    return SelfCenterView(controller: controller)
}
