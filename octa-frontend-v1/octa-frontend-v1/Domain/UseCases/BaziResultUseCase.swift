//
//  BaziResultUseCase.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI

struct BaziResultUseCase {
    let backendStatus: BackendConnectionStatus

    func loadPages(flowState: UserOnboardingFlowState) -> [BaziResultPage] {
        // TODO: 當接上真實後端時，調用 API 填入實際四句結果
        guard backendStatus == .connected else {
            return placeholderPages
        }
        // 目前後端尚未接入，先返回占位，未來可利用 flowState 內的 profileId/birth info 提供請求參數
        return placeholderPages
    }

    private var placeholderPages: [BaziResultPage] {
        [
            BaziResultPage(
                title: "纳音",
                detail: "与你相冲的能量是「庚金」，原本安稳的生活状态容易被突发事件打乱。",
                gradient: [
                    Color(red: 1.0, green: 0.99, blue: 0.96),
                    Color(red: 0.75, green: 0.87, blue: 1.0)
                ]
            ),
            BaziResultPage(
                title: "舒适区",
                detail: "保持充足睡眠以及规律作息，能让你的木火能量保持温和流动。",
                gradient: [
                    Color(red: 1.0, green: 0.98, blue: 0.95),
                    Color(red: 0.89, green: 0.92, blue: 1.0)
                ]
            ),
            BaziResultPage(
                title: "能量来源",
                detail: "与信任的友人分享心得，或专注于手作、写作等需要耐心的活动，可获得长久的内在滋养。",
                gradient: [
                    Color(red: 1.0, green: 0.95, blue: 0.95),
                    Color(red: 0.77, green: 0.88, blue: 1.0)
                ]
            ),
            BaziResultPage(
                title: "相冲能量",
                detail: "遇到任务堆叠时，先照顾好自己的节奏与界限，再决定要投入哪些链接，避免精力被过度消耗。",
                gradient: [
                    Color(red: 1.0, green: 0.99, blue: 0.95),
                    Color(red: 0.78, green: 0.93, blue: 0.85)
                ]
            )
        ]
    }
}
