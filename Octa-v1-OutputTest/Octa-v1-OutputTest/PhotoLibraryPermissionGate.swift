import SwiftUI
import Photos
import UIKit

struct PhotoLibraryPermissionGate<Content: View>: View {
    @State private var authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    @ViewBuilder let content: () -> Content

    var body: some View {
        Group {
            switch authorizationStatus {
            case .authorized, .limited:
                content()
            case .notDetermined:
                RequestPermissionView(requestAuthorization: requestAuthorization)
            default:
                DeniedPermissionView(openSettings: openSettings)
            }
        }
        .onAppear { refreshAuthorizationStatus() }
        .animation(.default, value: authorizationStatus)
    }

    private func refreshAuthorizationStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    private func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
            DispatchQueue.main.async {
                authorizationStatus = newStatus
            }
        }
    }

    private func openSettings() {
#if canImport(UIKit)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
#endif
    }
}

private struct RequestPermissionView: View {
    let requestAuthorization: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.tint)

            VStack(spacing: 8) {
                Text("需要访问您的相册")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("为了让 OutputTest 功能顺利处理您的工位照片，请允许应用访问相册。")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            Button(action: requestAuthorization) {
                Label("允许访问相册", systemImage: "checkmark.shield")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }
}

private struct DeniedPermissionView: View {
    let openSettings: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.orange)

            VStack(spacing: 8) {
                Text("无法读取相册照片")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("请在系统设置中为 Octa 允许照片访问权限后再继续使用 OutputTest。")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            Button(action: openSettings) {
                Label("前往设置", systemImage: "gearshape")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }
}
