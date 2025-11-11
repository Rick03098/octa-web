//
//  PermissionsView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct PermissionsView: View {
    @ObservedObject var controller: PermissionsController

    init(controller: PermissionsController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            DSColors.permissionsGradient
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {
                Button(action: controller.goBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(red: 0.14, green: 0.19, blue: 0.27))
                        .padding(12)
                }
                .buttonStyle(.plain)

                Text(DSStrings.Permissions.title)
                    .font(DSFonts.serifMedium(32))
                    .foregroundStyle(Color(red: 0.13, green: 0.18, blue: 0.32))

                VStack(spacing: 16) {
                    ForEach(controller.items) { item in
                        permissionRow(item)
                    }
                }

                Spacer()

                Button(action: controller.continueFlow) {
                    Text(DSStrings.Common.actionContinue)
                        .font(DSFonts.serifMedium(17))
                        .foregroundStyle(Color(red: 0.13, green: 0.17, blue: 0.29))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color.white.opacity(controller.canContinue ? 0.95 : 0.6))
                        )
                }
                .disabled(!controller.canContinue)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .onAppear {
                controller.reloadStatuses()
            }
        }
    }

    private func permissionRow(_ item: PermissionItemState) -> some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: item.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(red: 0.22, green: 0.24, blue: 0.33))
                Text(item.title)
                    .font(DSFonts.serifRegular(17))
                    .foregroundStyle(Color(red: 0.16, green: 0.21, blue: 0.33))
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { controller.items.first(where: { $0.id == item.id })?.isGranted ?? false },
                set: { newValue in
                    if newValue {
                        controller.togglePermission(for: item.type)
                    }
                }
            ))
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.99, green: 0.85, blue: 0.86)))
            .disabled(item.status == .denied && !item.isGranted)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color(red: 1.0, green: 0.92, blue: 0.93)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color(red: 0.93, green: 0.71, blue: 0.71).opacity(0.25), radius: 18, y: 10)
        )
    }
}

#Preview {
    let controller = PermissionsController(service: PermissionsService())
    return PermissionsView(controller: controller)
}
