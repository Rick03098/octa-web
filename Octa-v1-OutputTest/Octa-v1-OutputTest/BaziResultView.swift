import SwiftUI

struct BaziResultView: View {
    let result: BaziAnalysisResult
    let deskOrientation: CompassDirection
    let workspaceAnalysis: WorkspaceAnalysisResponse?

    var body: some View {
#if os(iOS)
        if #available(iOS 16.0, *) {
            content
        } else {
            content
        }
#else
        content
#endif
    }

    private var content: some View {
        List {
            if let locationName = result.locationName {
                Section("出生地点") {
                    Text(locationName)
                }
            }

            Section("工位信息") {
                Text("工位朝向：\(deskOrientation.promptValue)")
            }

            Section("四柱排盘") {
                pillarRow(title: "年柱", pillar: result.chart.yearPillar)
                pillarRow(title: "月柱", pillar: result.chart.monthPillar)
                pillarRow(title: "日柱", pillar: result.chart.dayPillar)
                pillarRow(title: "时柱", pillar: result.chart.hourPillar)
                Text("日主：\(result.chart.dayMaster)")
                    .font(.subheadline)
                    .padding(.top, 4)
            }

            Section("五行占比") {
                elementRow(label: "木", value: result.chart.elements.wood)
                elementRow(label: "火", value: result.chart.elements.fire)
                elementRow(label: "土", value: result.chart.elements.earth)
                elementRow(label: "金", value: result.chart.elements.metal)
                elementRow(label: "水", value: result.chart.elements.water)
            }

            Section("喜忌神") {
                if result.luckyElements.isEmpty {
                    Text("暂无喜用神分析结果。")
                        .foregroundStyle(.secondary)
                } else {
                    Text("喜用神：\(result.luckyElements.joined(separator: "、"))")
                }

                if result.unluckyElements.isEmpty {
                    Text("暂无忌神分析结果。")
                        .foregroundStyle(.secondary)
                } else {
                    Text("忌神：\(result.unluckyElements.joined(separator: "、"))")
                }
            }

            if let workspace = workspaceAnalysis {
                Section("工位四象分析") {
                    Text("青龙：\(workspace.si_xiang_problems.qinglong)")
                    Text("白虎：\(workspace.si_xiang_problems.baihu)")
                    Text("朱雀：\(workspace.si_xiang_problems.zhuque)")
                    Text("玄武：\(workspace.si_xiang_problems.xuanwu)")
                }

                Section("六合 / 六冲") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("六合：")
                            .font(.subheadline)
                            .bold()
                        Text(workspace.earthly_branch_analysis.liu_he)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Divider()
                        Text("六冲：")
                            .font(.subheadline)
                            .bold()
                        Text(workspace.earthly_branch_analysis.liu_chong)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("分析结果")
    }

    private func pillarRow(title: String, pillar: BaziPillar) -> some View {
        HStack {
            Text(title)
            Spacer()
            if pillar.heavenlyStem.isEmpty && pillar.earthlyBranch.isEmpty {
                Text("未提供")
                    .foregroundStyle(.secondary)
            } else {
                Text("\(pillar.heavenlyStem)\(pillar.earthlyBranch)")
                Text("(\(pillar.element))")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func elementRow(label: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                Spacer()
                Text(String(format: "%.2f%%", value))
                    .monospacedDigit()
            }
            ProgressView(value: value / 100.0)
                .progressViewStyle(.linear)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let samplePillar = BaziPillar(heavenlyStem: "甲", earthlyBranch: "子", element: "wood")
    let sampleChart = BaziChart(
        yearPillar: samplePillar,
        monthPillar: samplePillar,
        dayPillar: samplePillar,
        hourPillar: samplePillar,
        dayMaster: "甲",
        elements: BaziElements(wood: 40, fire: 20, earth: 10, metal: 20, water: 10)
    )
    let sampleResult = BaziAnalysisResult(
        chart: sampleChart,
        luckyElements: ["木", "水"],
        unluckyElements: ["金"],
        locationName: "上海市"
    )
    let sampleWorkspace = WorkspaceAnalysisResponse(
        si_xiang_problems: .init(qinglong: "青龙区域光线柔和，植物生长良好。",
                                 baihu: "白虎区域略显拥挤，可整理杂物。",
                                 zhuque: "朱雀面向通透，利于沟通演示。",
                                 xuanwu: "玄武靠背稳固，安全感充足。"),
        earthly_branch_analysis: .init(
            liu_he: "未见对应迹象",
            liu_chong: "子午冲：桌面放置的水杯正对暖光台灯，建议错位摆放以缓和冲突。"
        )
    )

    return NavigationView {
        BaziResultView(result: sampleResult,
                       deskOrientation: .east,
                       workspaceAnalysis: sampleWorkspace)
    }
}
