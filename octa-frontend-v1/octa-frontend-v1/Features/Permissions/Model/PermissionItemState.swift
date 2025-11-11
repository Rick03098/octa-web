//
//  PermissionItemState.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct PermissionItemState: Identifiable {
    let id = UUID()
    let type: PermissionType
    let title: String
    let iconName: String
    var status: PermissionStatus

    var isGranted: Bool {
        status == .granted
    }
}
