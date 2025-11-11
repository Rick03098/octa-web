//
//  FontRegistrar.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import CoreText

enum FontRegistrar {
    private static var hasRegistered = false

    private struct FontFile {
        let name: String
        let ext: String
    }

    private static let fontFiles: [FontFile] = [
        FontFile(name: "NotoSerifSC-Black", ext: "ttf"),
        FontFile(name: "NotoSerifSC-Bold", ext: "ttf"),
        FontFile(name: "NotoSerifSC-ExtraBold", ext: "ttf"),
        FontFile(name: "NotoSerifSC-ExtraLight", ext: "ttf"),
        FontFile(name: "NotoSerifSC-Light", ext: "ttf"),
        FontFile(name: "NotoSerifSC-Medium", ext: "ttf"),
        FontFile(name: "NotoSerifSC-Regular", ext: "ttf"),
        FontFile(name: "NotoSerifSC-SemiBold", ext: "ttf"),
        FontFile(name: "NotoSerifSC-VariableFont_wght", ext: "ttf"),
        FontFile(name: "SourceHanSerifSC-Bold", ext: "otf"),
        FontFile(name: "SourceHanSerifSC-ExtraLight", ext: "otf"),
        FontFile(name: "SourceHanSerifSC-Heavy", ext: "otf"),
        FontFile(name: "SourceHanSerifSC-Light", ext: "otf"),
        FontFile(name: "SourceHanSerifSC-Medium", ext: "otf"),
        FontFile(name: "SourceHanSerifSC-Regular", ext: "otf"),
        FontFile(name: "SourceHanSerifSC-SemiBold", ext: "otf")
    ]

    static func registerFontsIfNeeded() {
        guard !hasRegistered else { return }
        hasRegistered = true

        fontFiles.forEach { file in
            guard let url = urlForFont(named: file.name, ext: file.ext) else {
                return
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    private static func urlForFont(named name: String, ext: String) -> URL? {
        let bundle = Bundle.main
        if let url = bundle.url(forResource: "\(name).\(ext)", withExtension: nil) {
            return url
        }
        if let url = bundle.url(forResource: name, withExtension: ext, subdirectory: "Fonts") {
            return url
        }
        if let url = bundle.url(forResource: name, withExtension: ext, subdirectory: "Resources/Fonts") {
            return url
        }
        return bundle.url(forResource: name, withExtension: ext)
    }
}
