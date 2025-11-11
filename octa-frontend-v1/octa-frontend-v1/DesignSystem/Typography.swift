//
//  Typography.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

enum DSFonts {
    static func serifMedium(_ size: CGFloat) -> Font {
        Font.custom("NotoSerifSC-Medium", size: size)
    }

    static func serifRegular(_ size: CGFloat) -> Font {
        Font.custom("NotoSerifSC-Regular", size: size)
    }
}
