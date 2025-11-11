//
//  PermissionsController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

@MainActor
final class PermissionsController: ObservableObject {
    @Published private(set) var items: [PermissionItemState] = []

    private let service: PermissionsService
    var onContinue: (() -> Void)?
    var onBack: (() -> Void)?

    init(service: PermissionsService) {
        self.service = service
        reloadStatuses()
    }

    func reloadStatuses() {
        items = [
            PermissionItemState(type: .camera, title: DSStrings.Permissions.camera, iconName: "camera", status: service.status(for: .camera)),
            PermissionItemState(type: .microphone, title: DSStrings.Permissions.microphone, iconName: "mic", status: service.status(for: .microphone)),
            PermissionItemState(type: .location, title: DSStrings.Permissions.location, iconName: "location", status: service.status(for: .location))
        ]
    }

    func togglePermission(for type: PermissionType) {
        let current = service.status(for: type)
        guard current != .granted else { return }
        service.request(type) { [weak self] status in
            guard let self else { return }
            if let index = self.items.firstIndex(where: { $0.type == type }) {
                self.items[index].status = status
            }
        }
    }

    private var cameraGranted: Bool {
        items.first(where: { $0.type == .camera })?.isGranted ?? false
    }

    var canContinue: Bool {
        cameraGranted
    }

    func continueFlow() {
        guard canContinue else { return }
        onContinue?()
    }

    func goBack() {
        onBack?()
    }
}
