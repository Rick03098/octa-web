//
//  EnvironmentReportUseCase.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

struct EnvironmentReportUseCase {
    let backendStatus: BackendConnectionStatus

    func loadReport() -> EnvironmentReport {
        // TODO: 接通后端 API，使用环境 ID/任务 ID 拉取真实报告
        guard backendStatus == .connected else {
            return placeholderReport
        }
        return placeholderReport
    }

    private var placeholderReport: EnvironmentReport {
        EnvironmentReport(
            title: "他山",
            subtitle: DSStrings.Report.subtitle,
            sections: [
                EnvironmentReportSection(
                    title: "结构分析",
                    body: "《结构分析》亮点：台桌与陈列装饰处于安静但有呼吸感的布局，整体场域以白色与木色为主，借由少量植物和器物带出柔和能量，适合作为深度思考与整理的空间。"
                ),
                EnvironmentReportSection(
                    title: "风水建议",
                    body: "建议保持书桌左右通透，手边与桌面维持整洁，同时准备一盏暖黄小灯（或自然光），工具收纳、启闭有序，利于进取。"
                ),
                EnvironmentReportSection(
                    title: "能量补充",
                    body: "可以放置一株小型绿植、开启流动的音乐或扩香，帮助缓冲紧绷情绪，让灵感游离。"
                )
            ]
        )
    }
}
