import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BaziViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    SectionCard(title: "基本信息") {
                        DatePicker("出生日期", selection: $viewModel.birthDate, displayedComponents: .date)
                        DatePicker("出生时间", selection: $viewModel.birthTime, displayedComponents: .hourAndMinute)
                        Picker("性别", selection: $viewModel.gender) {
                            ForEach(Gender.allCases) { value in
                                Text(value.rawValue).tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    SectionCard(title: "出生地点") {
                        if !viewModel.hasAccessToken {
                            Text("请在 Info.plist 中配置 MAPBOX_ACCESS_TOKEN，用于调用 Mapbox 地理编码接口。")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            TextField("输入城市、地址或地标", text: $viewModel.searchQuery)
#if os(iOS)
                                .modifier(NoAutoCapitalizationModifier())
#endif
                                .disableAutocorrection(true)
                                .textFieldStyle(.roundedBorder)

                            Button {
                                Task { await viewModel.searchLocation() }
                            } label: {
                                Label("搜索地点", systemImage: "magnifyingglass")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!viewModel.canSearchLocation || viewModel.isSearching)
                        }

                        if viewModel.isSearching {
                            ProgressView().padding(.top, 4)
                        }

                        if let location = viewModel.selectedLocation {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("已选择：\(location.name)")
                                    .font(.subheadline)
                                if let timeZone = location.timeZone {
                                    Text("时区：\(timeZone.identifier)")
                                }
                                Text(String(format: "经度：%.4f，纬度：%.4f", location.longitude, location.latitude))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 8)
                        }
                    }

                    SectionCard(title: "工位朝向") {
                        CompassDirectionPicker(selectedDirection: $viewModel.deskOrientation)
                        Text("当前朝向：\(viewModel.deskOrientation.promptValue)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    SectionCard(title: "工位照片") {
                        WorkspacePhotoPicker(
                            imageData: $viewModel.workspaceImageData,
                            imageMimeType: $viewModel.workspaceImageMimeType
                        )
                    }

                    Button {
                        Task { await viewModel.generateWorkspaceAnalysis() }
                    } label: {
                        if viewModel.isGenerating {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("生成八字排盘")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.canGenerateAnalysis || viewModel.isGenerating)

                    if let message = viewModel.errorMessage {
                        SectionCard(title: "提示") {
                            Text(message)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
            }
            .background(navigationLink)
            .navigationTitle("八字排盘")
        }
    }

    private var navigationLink: some View {
        NavigationLink(
            destination: Group {
                if let result = viewModel.analysisResult {
                    BaziResultView(
                        result: result,
                        deskOrientation: viewModel.deskOrientation,
                        workspaceAnalysis: viewModel.workspaceAnalysis
                    )
                    .onDisappear {
                        viewModel.shouldShowResult = false
                        viewModel.analysisResult = nil
                        viewModel.workspaceAnalysis = nil
                    }
                } else {
                    EmptyView()
                }
            },
            isActive: Binding(
                get: { viewModel.shouldShowResult },
                set: { viewModel.shouldShowResult = $0 }
            ),
            label: { EmptyView() }
        )
        .hidden()
    }
}

private let useLiquidGlassEffect = true

private struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        if useLiquidGlassEffect {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.headline)
                content
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, y: 6)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.headline)
                content
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
            )
        }
    }
}

enum Gender: String, CaseIterable, Identifiable {
    case male = "男"
    case female = "女"
    case other = "其他"

    var id: String { rawValue }
}

#if os(iOS)
private struct NoAutoCapitalizationModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.textInputAutocapitalization(.never)
        } else {
            content.autocapitalization(.none)
        }
    }
}
#endif

#Preview {
    ContentView()
}
