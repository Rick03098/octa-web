import Foundation

struct WorkspacePromptPayload {
    let prompt: String
    let dayMasterElement: String
    let deskOrientation: String
    let userGender: String
}

enum WorkspacePromptPayloadError: LocalizedError {
    case missingDayMaster

    var errorDescription: String? {
        switch self {
        case .missingDayMaster:
            return "缺少日主信息，无法生成工位分析提示词。"
        }
    }
}

struct WorkspacePromptPayloadBuilder {
    private let promptManager = WorkspacePromptManager()

    func buildStructuredPayload(
        chart: BaziChart,
        gender: Gender,
        deskOrientation: CompassDirection,
        workspaceImagePlaceholder: String = "[INLINE_IMAGE]"
    ) throws -> WorkspacePromptPayload {
        guard !chart.dayMaster.isEmpty else {
            throw WorkspacePromptPayloadError.missingDayMaster
        }

        let orientationText = deskOrientation.promptValue

        let prompt = try promptManager.structuredPrompt(
            dayMasterElement: chart.dayMaster,
            deskOrientation: orientationText,
            workspaceImage: workspaceImagePlaceholder,
            userGender: gender.rawValue
        )

        return WorkspacePromptPayload(
            prompt: prompt,
            dayMasterElement: chart.dayMaster,
            deskOrientation: orientationText,
            userGender: gender.rawValue
        )
    }
}
