//
//  CaptureCameraView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct CaptureCameraView: View {
    @ObservedObject var controller: CaptureCameraController

    init(controller: CaptureCameraController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [
                    Color.black.opacity(0.35),
                    Color.clear,
                    Color.black.opacity(0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: controller.goBack) {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 42, height: 42)
                            .overlay(
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.white)
                            )
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button(action: {}) {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 42, height: 42)
                            .overlay(
                                Image(systemName: "gearshape")
                                    .foregroundStyle(.white)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                captureFrame

                Spacer()

                controlBar
            }
        }
    }

    private var captureFrame: some View {
        GeometryReader { proxy in
            let width = proxy.size.width * 0.8
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .stroke(Color.white.opacity(0.8), lineWidth: 4)
                .frame(width: width, height: width * 1.1)
                .overlay(
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        .padding(12)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    private var controlBar: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {}) {
                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 2)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "bolt.fill")
                                .foregroundStyle(.white)
                        )
                }
                .buttonStyle(.plain)
                .disabled(true)

                Spacer()

                Button(action: controller.capture) {
                    Circle()
                        .stroke(Color.white, lineWidth: 6)
                        .frame(width: 82, height: 82)
                        .overlay(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 64, height: 64)
                        )
                }
                .buttonStyle(.plain)

                Spacer()

                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 2, height: 18)
                    )
            }
            .padding(.horizontal, 40)

            Capsule()
                .fill(Color.white.opacity(0.9))
                .frame(width: 160, height: 4)
        }
        .padding(.bottom, 28)
    }
}

#Preview {
    CaptureCameraView(controller: CaptureCameraController())
}
