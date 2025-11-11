//
//  EnvironmentReportSection.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

struct EnvironmentReportSection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

struct EnvironmentReport {
    let title: String
    let subtitle: String
    let sections: [EnvironmentReportSection]
}
