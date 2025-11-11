//
//  DashboardTabButton.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct DashboardTabButton: View {
    let title: String
    let systemImage: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(DSFonts.serifRegular(16))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .foregroundStyle(isActive ? Color.white : Color(red: 0.3, green: 0.33, blue: 0.4))
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(isActive ? Color(red: 0.98, green: 0.73, blue: 0.81) : Color.white.opacity(0.7))
            )
        }
        .buttonStyle(.plain)
        .disabled(isActive)
    }
}
