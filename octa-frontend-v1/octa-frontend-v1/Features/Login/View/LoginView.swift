//
//  LoginView.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var controller: LoginController

    init(controller: LoginController) {
        self.controller = controller
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                LottieLoopView(resourceName: "login-background-video")
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .ignoresSafeArea()

                VStack(spacing: 28) {
                    VStack(spacing: 18) {
                        primaryButton(title: DSStrings.Login.createAccount, action: controller.handleCreateAccount)
                        secondaryButton(title: DSStrings.Login.loginGoogle, action: controller.handleGoogleLogin)
                    }

                    Button(action: controller.handleMemberLogin) {
                        Text(DSStrings.Login.memberLogin)
                            .font(DSFonts.serifRegular(15))
                            .foregroundStyle(Color(red: 0.23, green: 0.28, blue: 0.35))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 25)
                .padding(.top, 40)
                .padding(.bottom, proxy.safeAreaInsets.bottom + 32)
                .frame(maxWidth: .infinity)
                .background(
                    Color.white
                        .clipShape(TopRoundedShape(radius: 24))
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(DSFonts.serifMedium(18))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(red: 0.21, green: 0.21, blue: 0.21))
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
                )
        }
        .buttonStyle(.plain)
    }

    private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(DSFonts.serifMedium(16))
                .foregroundStyle(Color(red: 0.04, green: 0.10, blue: 0.19).opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(LinearGradient(
                            colors: [
                                Color.white.opacity(0.9),
                                Color.white.opacity(0.75)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

private struct TopRoundedShape: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tr = min(min(radius, rect.width / 2), rect.height)
        let tl = tr

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(
            center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
            radius: tl,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
            radius: tr,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    let controller = LoginController()
    return LoginView(controller: controller)
}
