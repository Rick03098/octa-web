import Foundation
import Combine

struct BaziAnalysisResult: Identifiable {
    let id = UUID()
    let chart: BaziChart
    let luckyElements: [String]
    let unluckyElements: [String]
    let locationName: String?
}

@MainActor
final class BaziViewModel: ObservableObject {
    @Published var birthDate: Date
    @Published var birthTime: Date
    @Published var gender: Gender = .female

    @Published var searchQuery: String = ""
    @Published var selectedLocation: ResolvedLocation?
    @Published var deskOrientation: CompassDirection = .north
    @Published var workspaceImageData: Data?
    @Published var workspaceImageMimeType: String = "image/jpeg"

    @Published var isSearching: Bool = false
    @Published var isGenerating: Bool = false

    @Published var analysisResult: BaziAnalysisResult?
    @Published var workspaceAnalysis: WorkspaceAnalysisResponse?
    @Published var errorMessage: String?
    @Published var shouldShowResult: Bool = false

    private let baziService = BaziService()
    private let payloadBuilder = WorkspacePromptPayloadBuilder()
    private let accessToken: String
    private let locationService: LocationSearchService?
#if canImport(GoogleGenerativeAI) && os(iOS)
    private let geminiAnalyzer: GeminiWorkspaceAnalyzer?
#endif

    init(now: Date = Date()) {
        self.birthDate = now
        self.birthTime = now
        self.accessToken = MapboxConfig.accessToken
        if accessToken.isEmpty {
            self.locationService = nil
        } else {
            self.locationService = LocationSearchService(accessToken: accessToken)
        }
#if canImport(GoogleGenerativeAI) && os(iOS)
        if #available(iOS 15.0, *) {
            self.geminiAnalyzer = GeminiWorkspaceAnalyzer(apiKey: GeminiConfig.apiKey)
        } else {
            self.geminiAnalyzer = nil
        }
#endif
    }

    var hasAccessToken: Bool { !accessToken.isEmpty }

    var canSearchLocation: Bool {
        hasAccessToken && !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canGenerateAnalysis: Bool {
        hasAccessToken && selectedLocation != nil && workspaceImageData != nil
    }

    func searchLocation(limit: Int = 5) async {
        guard canSearchLocation else { return }
        guard let locationService else {
            errorMessage = "缺少 Mapbox Access Token，无法搜索地点。"
            resetResults()
            return
        }

        isSearching = true
        errorMessage = nil

        do {
            let results = try await locationService.search(query: searchQuery, limit: limit)
            if let first = results.first {
                selectedLocation = first
            } else {
                errorMessage = "未找到匹配的地点，请尝试更具体的描述。"
                selectedLocation = nil
            }
        } catch {
#if DEBUG
            print("[Mapbox] search error:", error)
#endif
            errorMessage = error.localizedDescription
            selectedLocation = nil
        }

        isSearching = false
    }

    func generateWorkspaceAnalysis() async {
        guard let location = selectedLocation else {
            errorMessage = "请先选择出生地点。"
            resetResults()
            return
        }
        guard let timeZone = location.timeZone else {
            errorMessage = "该地点缺少时区信息。"
            resetResults()
            return
        }
        guard let imageData = workspaceImageData else {
            errorMessage = "请先上传工位照片。"
            resetResults()
            return
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: birthDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: birthTime)

        guard
            let year = dateComponents.year,
            let month = dateComponents.month,
            let day = dateComponents.day,
            let hour = timeComponents.hour,
            let minute = timeComponents.minute
        else {
            errorMessage = "无法解析出生日期或时间。"
            resetResults()
            return
        }

        errorMessage = nil
        isGenerating = true
        defer { isGenerating = false }

        let birthInfo = BirthInfo(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            timeZone: timeZone,
            longitude: location.longitude
        )

        do {
            let computedChart = try baziService.calculateChart(for: birthInfo)
            let luckyAnalysis = baziService.analyzeLuckyElements(chart: computedChart)
            analysisResult = BaziAnalysisResult(
                chart: computedChart,
                luckyElements: luckyAnalysis.lucky,
                unluckyElements: luckyAnalysis.unlucky,
                locationName: location.name
            )

            let payload = try payloadBuilder.buildStructuredPayload(
                chart: computedChart,
                gender: gender,
                deskOrientation: deskOrientation
            )

#if canImport(GoogleGenerativeAI) && os(iOS)
            if #available(iOS 15.0, *), let analyzer = geminiAnalyzer {
                let request = WorkspaceRequest(
                    dayMasterElement: payload.dayMasterElement,
                    deskOrientation: payload.deskOrientation,
                    workspaceImageData: imageData,
                    workspaceImageMimeType: workspaceImageMimeType,
                    userGender: payload.userGender
                )
                workspaceAnalysis = try await analyzer.analyzeWorkspace(request)
            } else {
                workspaceAnalysis = nil
            }
#else
            workspaceAnalysis = nil
#endif

            shouldShowResult = true
        } catch {
            errorMessage = error.localizedDescription
            resetResults()
        }
    }

    private func resetResults() {
        analysisResult = nil
        workspaceAnalysis = nil
        shouldShowResult = false
    }
}
