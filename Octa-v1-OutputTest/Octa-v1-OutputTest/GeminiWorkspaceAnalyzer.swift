import Foundation
#if canImport(GoogleGenerativeAI) && os(iOS)
import GoogleGenerativeAI

@available(iOS 15.0, *)
final class GeminiWorkspaceAnalyzer {
    private let model: GenerativeModel
    private let promptManager = WorkspacePromptManager()

    init(apiKey: String, modelName: String = "gemini-2.5-pro") {
        model = GenerativeModel(name: modelName, apiKey: apiKey)
    }

    func analyzeWorkspace(_ request: WorkspaceRequest) async throws -> WorkspaceAnalysisResponse {
        let prompt = try promptManager.structuredPrompt(
            dayMasterElement: request.dayMasterElement,
            deskOrientation: request.deskOrientation,
            workspaceImage: "[INLINE_IMAGE]",
            userGender: request.userGender
        )

        let content = ModelContent(
            role: "user",
            parts: [
                .text(prompt),
                .data(mimetype: request.workspaceImageMimeType, request.workspaceImageData)
            ]
        )

        let response = try await model.generateContent([content])

        guard let jsonString = response.text else {
            throw PromptError.invalidResponse
        }

        let data = Data(jsonString.utf8)
        return try JSONDecoder().decode(WorkspaceAnalysisResponse.self, from: data)
    }
}
#endif
