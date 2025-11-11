//
//  Colors.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

enum DSColors {
    /// 名字信息頁的背景漸變，包含 Liquid Glass 的 fallback。
    static var nameEntryGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.63, blue: 0.63),
                Color(red: 1.0, green: 0.86, blue: 0.81)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// 生日信息頁的背景漸變。
    static var birthdayGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.76, green: 0.94, blue: 0.86),
                Color(red: 0.98, green: 0.83, blue: 0.90)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// 出生時間頁背景漸變 (藍色到奶白的柔和漸變)。
    static var birthTimeGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [
                Color(red: 0.65, green: 0.84, blue: 0.99),
                Color(red: 0.78, green: 0.92, blue: 1.0),
                Color(red: 0.97, green: 0.94, blue: 0.89),
                Color(red: 0.99, green: 0.96, blue: 0.92)
            ]),
            center: .top,
            startAngle: .degrees(-90),
            endAngle: .degrees(270)
        )
    }

    static var birthTimeRadialHighlight: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: [
                Color(red: 0.78, green: 0.94, blue: 1.0),
                Color(red: 0.99, green: 0.97, blue: 0.93)
            ]),
            center: .center,
            startRadius: 120,
            endRadius: 360
        )
    }

    /// 出生地頁背景漸變。
    static var birthLocationGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.69, green: 0.62, blue: 0.58),
                Color(red: 0.98, green: 0.93, blue: 0.88)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// 性別頁背景漸變。
    static var genderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.86, green: 0.83, blue: 0.82),
                Color(red: 0.99, green: 0.97, blue: 0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var permissionsGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.94, blue: 0.94),
                Color(red: 1.0, green: 0.98, blue: 0.96)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var mainEnvironmentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.97, blue: 0.95),
                Color(red: 1.0, green: 0.88, blue: 0.92),
                Color(red: 1.0, green: 0.98, blue: 0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var selfCenterGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.99, green: 0.94, blue: 0.90),
                Color(red: 0.97, green: 0.93, blue: 0.96),
                Color(red: 0.94, green: 0.92, blue: 0.98)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var reportGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.9, green: 0.96, blue: 1.0),
                Color(red: 0.97, green: 0.97, blue: 0.94)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
