import Foundation

enum PromptError: Error {
    case missingVariables([String])
    case invalidDayMaster(String)
    case invalidResponse
}

struct PromptTemplate {
    let template: String
    let variables: [String]

    func render(with data: [String: String]) throws -> String {
        let missing = variables.filter { data[$0] == nil }
        if !missing.isEmpty {
            throw PromptError.missingVariables(missing)
        }

        return variables.reduce(template) { result, key in
            result.replacingOccurrences(of: "${\(key)}", with: data[key]!)
        }
    }
}

enum DayMasterNormalizer {
    private static let dayMasterToElement: [String: String] = [
        "甲": "wood", "乙": "wood",
        "丙": "fire", "丁": "fire",
        "戊": "earth", "己": "earth",
        "庚": "metal", "辛": "metal",
        "壬": "water", "癸": "water",
        "wood": "wood", "fire": "fire",
        "earth": "earth", "metal": "metal",
        "water": "water"
    ]

    static func normalize(_ rawValue: String) -> String? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let key = trimmed.lowercased()
        return dayMasterToElement[key] ?? key
    }
}

struct StructuredWorkspacePromptBuilder {
    private static let baseTemplate = #"""
你是一位温和而洞察入微的风水顾问，气质近似 INFJ。  
你只依据以下输入进行细致观察：
- 日主：${day_master_element}（<<STEMS_LABEL>>）
- 用户性别：${user_gender}
- 工位朝向：${desk_orientation}
- 工位图像：${workspace_image}（工位桌面的正前方和面向方位为朱雀，左侧桌面以及座位左面的区域为青龙，右侧桌面以及座位右面的区域为白虎，背后区域为玄武）

请以有温度的语言书写分析，让人感到被理解，而非被评判。  
文风要带有象征与节奏感，像一位懂空间与人心的诗人。  
<<ELEMENT_FOCUS>>

---

### 一、四象观察
以朱雀、青龙、白虎、玄武四象为线索，写出工位气场印象：

- **青龙（左侧）**：象征灵感、援手与创造，如同你的左臂。  
  观察左侧的层次与生机。若太低、太乱或毫无活气，象征构思受限；若有绿植、书籍、柔光，寓意思维被滋养、有人相助。

- **白虎（右侧）**：象征执行、界限与行动，如同你的右臂。  
  若右侧压迫、堆叠、或摆有尖锐金属，暗示紧张与冲突；若简洁有序、留白适度，则象征果断与稳健。

- **朱雀（前方）**：象征表达与远望，是你的“未来之窗”。  
  观察前方是否开阔、有光、有屏幕或门窗。若被遮挡、昏暗或闭塞，代表沟通与机会受限；若光线流动、空间明亮，则象征启发与舞台。

- **玄武（背后）**：象征根基与安全，像安静的山丘。  
  若背后空荡或无靠，易生不安与分神；若有靠背、墙面或温暖装饰，则寓意稳固、被支持。

每一象都需“先写亮点，再写隐忧”，并结合 ${user_gender} 的角色（如职场身份、家庭关系或情感期待），  
解释这种空间状态如何折射他们的内在节奏与人际能量流。

---

### 二、地支气场
工位面向的方位是${desk_orientation}，请你把工位周围的方向映射至十二地支：
北=子、东北=丑/寅、东=卯、东南=辰/巳、南=午、西南=未/申、西=酉、西北=戌/亥。  
观察物件的分布与呼应，判断是否形成“六合”或“六冲”：  
例如——子位水缸与午位火源为子午冲；辰位绿植与戌位蜡烛为辰戌冲。  
合为气顺、冲为气逆，先说明方位证据短句（比如是“子位见水杯，午位见红色灯，形成子午冲”，再请说明其象征与影响。

---

### 三、合冲笔记
以细腻语气描述是否观察到以下组合：

- **六合**：若出现下列呼应，请写出触发方位及积极意义；若未见，请写“未见对应迹象”。
<<LIUHE_TEXT>>

- **六冲**：若出现下列对冲，请说明触发方位与潜在风险；若未见，请写“未见对应迹象”。
<<LIUCHONG_TEXT>>

---

### 输出格式
请严格返回合法 JSON，不得添加额外说明或 Markdown。
结构如下：
{
    "si_xiang_problems": {
        "qinglong": "...",
        "baihu": "...",
        "zhuque": "...",
        "xuanwu": "..."
    },
    "earthly_branch_analysis": {
        "liu_he": "...",
        "liu_chong": "..."
    }
}
"""#

    private static func formattedTemplate(stemsLabel: String,
                                          elementFocus: String,
                                          liuhePairs: [(String, String)],
                                          liuchongPairs: [(String, String)]) -> PromptTemplate {
        let liuheText = liuhePairs
            .map { "    - \($0.0)：\($0.1)" }
            .joined(separator: "\n")
        let liuchongText = liuchongPairs
            .map { "    - \($0.0)：\($0.1)" }
            .joined(separator: "\n")

        var template = baseTemplate
        template = template.replacingOccurrences(of: "<<STEMS_LABEL>>", with: stemsLabel)
        template = template.replacingOccurrences(of: "<<ELEMENT_FOCUS>>", with: elementFocus)
        template = template.replacingOccurrences(of: "<<LIUHE_TEXT>>", with: liuheText)
        template = template.replacingOccurrences(of: "<<LIUCHONG_TEXT>>", with: liuchongText)

        return PromptTemplate(
            template: template,
            variables: ["day_master_element", "desk_orientation", "workspace_image", "user_gender"]
        )
    }

    private static let templates: [String: PromptTemplate] = {
        [
            "wood": formattedTemplate(
                stemsLabel: "甲/乙木",
                elementFocus: "木日主如树，重生长、讲秩序。青龙代表枝叶向外舒展，白虎是修剪的刀，朱雀是花，玄武是根。木人若左右平衡，则思想与行动皆能成林。",
                liuhePairs: [
                    ("戌卯合", "合作有成，表达顺畅，旧友或合作关系回温"),
                    ("寅亥合", "志同道合的支持，缓解焦虑与孤立感"),
                    ("子丑合", "资源合并，男性得财，家庭稳定"),
                    ("辰酉合", "晋升与薪酬双利，伴随金钱投入"),
                    ("巳申合", "上级赏识与女性情缘并行，沟通增多"),
                    ("午未合", "财运与情感双收，思维灵动")
                ],
                liuchongPairs: [
                    ("子午冲", "情绪波动，资源不稳，女性需关心生理健康"),
                    ("未丑冲", "财库受扰，男性易陷情绪低谷"),
                    ("寅申冲", "出行与人际纷争多，女性易遭误解"),
                    ("卯酉冲", "感情与合作受阻，警惕口舌纷争"),
                    ("辰戌冲", "得失并存，男性声誉易受冲击"),
                    ("巳亥冲", "事业与家庭拉扯，情绪起伏大")
                ]
            ),
            "fire": formattedTemplate(
                stemsLabel: "丙/丁火",
                elementFocus: "火日主如焰，明朗而热切。朱雀是火的核心，青龙助燃灵感，白虎决定火势方向，玄武令热情不致失控。火旺而稳，则温暖众人。",
                liuhePairs: [
                    ("卯戌合", "资源整合、上司扶持，助力火势正旺"),
                    ("寅亥合", "职位上升、女性感情顺畅，权力得承认"),
                    ("子丑合", "财库稳固，灵感化收益"),
                    ("辰酉合", "偏财与兴趣并进，男性桃花温和有助"),
                    ("巳申合", "合作激发创意，虽有摩擦终见成效"),
                    ("午未合", "人际和缓、情绪舒展")
                ],
                liuchongPairs: [
                    ("子午冲", "女性感情与职场波动，需控制情绪过热"),
                    ("未丑冲", "压力骤升，身体虚耗，女性生殖健康需留意"),
                    ("寅申冲", "财运起伏，男性情感易起矛盾"),
                    ("卯酉冲", "投资误判，男性需警惕烂桃花"),
                    ("辰戌冲", "过度投入导致疲惫，女性健康受影响"),
                    ("巳亥冲", "职场震荡或流言，需稳住节奏")
                ]
            ),
            "earth": formattedTemplate(
                stemsLabel: "戊/己土",
                elementFocus: "土日主如原野，重承载与秩序。青龙与白虎如护城墙，朱雀为沟通之门，玄武是山之根。土稳，则众事安。",
                liuhePairs: [
                    ("卯戌合", "合作稳固，体制内机缘增"),
                    ("寅亥合", "晋升与情感并进，上司赏识"),
                    ("子丑合", "合作得财，兄弟助力"),
                    ("辰酉合", "友情修复，压力化解"),
                    ("巳申合", "权力增长伴随责任"),
                    ("午未合", "同盟结交，人际和缓")
                ],
                liuchongPairs: [
                    ("子午冲", "财运冲击，男性易遇短暂情缘"),
                    ("未丑冲", "合作摩擦，健康受损"),
                    ("寅申冲", "女性受压，职场受限"),
                    ("卯酉冲", "感情易生第三者，合作波动"),
                    ("辰戌冲", "金钱与声誉之争"),
                    ("巳亥冲", "奔波劳累，收益不稳")
                ]
            ),
            "metal": formattedTemplate(
                stemsLabel: "庚/辛金",
                elementFocus: "金日主如刃，重秩序与锋芒。青龙与白虎为双刃，朱雀为舞台，玄武为鞘。金要懂收放，锋利方可成器。",
                liuhePairs: [
                    ("卯戌合", "资源整合、男性感情温润"),
                    ("寅亥合", "灵感与偏财并进"),
                    ("子丑合", "权力放大，女性得照拂"),
                    ("辰酉合", "伙伴互补，关系修复"),
                    ("巳申合", "竞争促成长"),
                    ("午未合", "职位与情感同步提升")
                ],
                liuchongPairs: [
                    ("子午冲", "女性感情与合作受阻，工作/上下级关系受压制"),
                    ("未丑冲", "资产震荡、家庭摇摆"),
                    ("寅申冲", "男性感情动荡，合伙猜疑"),
                    ("卯酉冲", "财运反复，需防冲动投资"),
                    ("辰戌冲", "小人干扰，名誉波动"),
                    ("巳亥冲", "女性事业受阻，或调岗转向")
                ]
            ),
            "water": formattedTemplate(
                stemsLabel: "壬/癸水",
                elementFocus: "水日主如流，重灵动与通达。朱雀为远景，青龙为灵感，白虎为执行，玄武为承托。若水得其道，则情绪与思维并流。",
                liuhePairs: [
                    ("卯戌合", "晋升与感情并进，女性得益"),
                    ("寅亥合", "益友扶持，孤独感消融"),
                    ("子丑合", "职位上升，男性突破限制"),
                    ("辰酉合", "资源流通，女性获助"),
                    ("巳申合", "出行得机缘，事业合财兼得，合伙合作，男性桃花运提升，女性财运提升"),
                    ("午未合", "职场与感情双向突破")
                ],
                liuchongPairs: [
                    ("子午冲", "职位变动，女性感情紧张"),
                    ("未丑冲", "人际失衡，易起利益纷争"),
                    ("寅申冲", "奔波劳累，身心疲惫"),
                    ("卯酉冲", "家庭与资产波动"),
                    ("辰戌冲", "官司与口舌之忧"),
                    ("巳亥冲", "男性感情多变，易生竞争")
                ]
            )
        ]
    }()

    static func generate(dayMasterElement: String,
                         deskOrientation: String,
                         workspaceImage: String,
                         userGender: String) throws -> String {
        guard let normalized = DayMasterNormalizer.normalize(dayMasterElement) else {
            throw PromptError.invalidDayMaster(dayMasterElement)
        }
        guard let template = templates[normalized] else {
            throw PromptError.invalidDayMaster(dayMasterElement)
        }

        return try template.render(with: [
            "day_master_element": dayMasterElement,
            "desk_orientation": deskOrientation,
            "workspace_image": workspaceImage,
            "user_gender": userGender
        ])
    }
}

final class WorkspacePromptManager {
    enum AnalysisType {
        case full
        case quick
    }

    private let languagePrompts: [String: [String: PromptTemplate]]

    init() {
        let zhSystem = PromptTemplate(
            template: #"""
你是一位专业的风水大师，精通传统风水学和现代空间设计。
你的任务是分析用户的工位照片，并结合其八字信息提供个性化的风水建议。

分析原则：
1. 结合传统风水理论与现代办公环境
2. 根据用户的八字五行喜忌给出针对性建议
3. 建议要实用、可执行，避免迷信色彩
4. 注重空间的能量流动和使用者的舒适度

用户八字信息：
${bazi_info}

请以JSON格式返回分析结果。
"""#,
            variables: ["bazi_info"]
        )

        let zhAnalysis = PromptTemplate(
            template: #"""
请分析这张工位照片的风水情况。

用户信息：
- 八字：${year_pillar} ${month_pillar} ${day_pillar} ${hour_pillar}
- 日主：${day_master}
- 五行分布：木${wood}% 火${fire}% 土${earth}% 金${metal}% 水${water}%
- 喜用神：${lucky_elements}
- 忌神：${unlucky_elements}

分析要点：
1. 办公桌位置评估
   - 是否背有靠山
   - 是否面向门窗
   - 是否有横梁压顶

2. 五行元素平衡
   - 现有环境的五行分布
   - 与用户八字的匹配度
   - 需要补充或减少的元素

3. 能量流动分析
   - 气流是否通畅
   - 是否有煞气（尖角、直冲等）
   - 光线是否适宜

4. 改善建议
   - 摆放建议（植物、装饰品等）
   - 颜色调整（基于喜用神）
   - 方位优化

请返回JSON格式：
{
    "overall_score": 0-100的整数,
    "desk_position": {
        "score": 0-100,
        "description": "描述",
        "issues": ["问题1", "问题2"]
    },
    "element_balance": {
        "current_elements": {"wood": %, "fire": %, "earth": %, "metal": %, "water": %},
        "compatibility_score": 0-100,
        "missing_elements": ["元素"],
        "excess_elements": ["元素"]
    },
    "energy_flow": {
        "score": 0-100,
        "positive_aspects": ["正面1", "正面2"],
        "negative_aspects": ["负面1", "负面2"]
    },
    "recommendations": [
        {
            "category": "placement/color/decoration/direction",
            "priority": "high/medium/low",
            "title": "建议标题",
            "description": "详细说明",
            "expected_benefit": "预期效果"
        }
    ],
    "summary": "总体评价（100字以内）"
}
"""#,
            variables: [
                "year_pillar", "month_pillar", "day_pillar", "hour_pillar",
                "day_master", "wood", "fire", "earth", "metal", "water",
                "lucky_elements", "unlucky_elements"
            ]
        )

        let zhQuick = PromptTemplate(
            template: #"""
快速分析工位风水。

用户喜用神：${lucky_elements}
用户忌神：${unlucky_elements}

请给出3-5条最重要的改善建议，返回JSON：
{
    "quick_tips": [
        {
            "tip": "建议内容",
            "reason": "原因",
            "difficulty": "easy/medium/hard"
        }
    ]
}
"""#,
            variables: ["lucky_elements", "unlucky_elements"]
        )

        let enSystem = PromptTemplate(
            template: #"""
You are a professional Feng Shui master, skilled in both traditional Feng Shui and modern space design.
Your task is to analyze the user's workspace photo and provide personalized Feng Shui advice based on their Bazi information.

Analysis principles:
1. Combine traditional Feng Shui theory with modern office environments
2. Provide targeted suggestions based on the user's Bazi elements
3. Suggestions should be practical and actionable, avoiding superstition
4. Focus on energy flow and user comfort

User's Bazi information:
${bazi_info}

Please return the analysis in JSON format.
"""#,
            variables: ["bazi_info"]
        )

        let enAnalysis = PromptTemplate(
            template: #"""
Please analyze the Feng Shui of this workspace photo.

User Information:
- Bazi: ${year_pillar} ${month_pillar} ${day_pillar} ${hour_pillar}
- Day Master: ${day_master}
- Five Elements: Wood ${wood}% Fire ${fire}% Earth ${earth}% Metal ${metal}% Water ${water}%
- Lucky Elements: ${lucky_elements}
- Unlucky Elements: ${unlucky_elements}

Analysis Points:
1. Desk Position Assessment
   - Back support
   - Facing direction
   - Overhead beams

2. Five Elements Balance
   - Current environmental elements
   - Compatibility with user's Bazi
   - Elements to add or reduce

3. Energy Flow Analysis
   - Air circulation
   - Sha Qi (sharp corners, direct confrontation)
   - Lighting conditions

4. Improvement Suggestions
   - Placement recommendations
   - Color adjustments
   - Direction optimization

Return in JSON format:
{
    "overall_score": integer 0-100,
    "desk_position": {
        "score": 0-100,
        "description": "description",
        "issues": ["issue1", "issue2"]
    },
    "element_balance": {
        "current_elements": {"wood": %, "fire": %, "earth": %, "metal": %, "water": %},
        "compatibility_score": 0-100,
        "missing_elements": ["element"],
        "excess_elements": ["element"]
    },
    "energy_flow": {
        "score": 0-100,
        "positive_aspects": ["positive1", "positive2"],
        "negative_aspects": ["negative1", "negative2"]
    },
    "recommendations": [
        {
            "category": "placement/color/decoration/direction",
            "priority": "high/medium/low",
            "title": "suggestion title",
            "description": "detailed description",
            "expected_benefit": "expected outcome"
        }
    ],
    "summary": "Overall evaluation (within 100 words)"
}
"""#,
            variables: [
                "year_pillar", "month_pillar", "day_pillar", "hour_pillar",
                "day_master", "wood", "fire", "earth", "metal", "water",
                "lucky_elements", "unlucky_elements"
            ]
        )

        languagePrompts = [
            "zh": [
                "system": zhSystem,
                "analysis": zhAnalysis,
                "quick_analysis": zhQuick
            ],
            "en": [
                "system": enSystem,
                "analysis": enAnalysis
            ]
        ]
    }

    func structuredPrompt(dayMasterElement: String,
                          deskOrientation: String,
                          workspaceImage: String,
                          userGender: String) throws -> String {
        try StructuredWorkspacePromptBuilder.generate(
            dayMasterElement: dayMasterElement,
            deskOrientation: deskOrientation,
            workspaceImage: workspaceImage,
            userGender: userGender
        )
    }

    func systemPrompt(language: String = "zh") -> String? {
        languagePrompts[language]?["system"]?.template
    }

    func analysisPrompt(language: String = "zh",
                        type: AnalysisType = .full,
                        variables: [String: String]) throws -> String {
        let langPrompts = languagePrompts[language] ?? languagePrompts["zh"] ?? [:]
        let key = type == .quick ? "quick_analysis" : "analysis"
        guard let template = langPrompts[key] else {
            throw PromptError.missingVariables([key])
        }
        return try template.render(with: variables)
    }
}

struct WorkspaceRequest {
    let dayMasterElement: String
    let deskOrientation: String
    let workspaceImageData: Data
    let workspaceImageMimeType: String
    let userGender: String

    init(dayMasterElement: String,
         deskOrientation: String,
         workspaceImageData: Data,
         workspaceImageMimeType: String = "image/jpeg",
         userGender: String) {
        self.dayMasterElement = dayMasterElement
        self.deskOrientation = deskOrientation
        self.workspaceImageData = workspaceImageData
        self.workspaceImageMimeType = workspaceImageMimeType
        self.userGender = userGender
    }
}

struct WorkspaceAnalysisResponse: Decodable {
    struct FourSymbols: Decodable {
        let qinglong: String
        let baihu: String
        let zhuque: String
        let xuanwu: String
    }

    struct EarthlyBranchAnalysis: Decodable {
        let liu_he: String
        let liu_chong: String
    }

    let si_xiang_problems: FourSymbols
    let earthly_branch_analysis: EarthlyBranchAnalysis
}

final class WorkspaceAnalyzer {
    private let promptManager = WorkspacePromptManager()

    func buildStructuredPrompt(for request: WorkspaceRequest) throws -> String {
        try promptManager.structuredPrompt(
            dayMasterElement: request.dayMasterElement,
            deskOrientation: request.deskOrientation,
            workspaceImage: "[INLINE_IMAGE]",
            userGender: request.userGender
        )
    }

    func buildAnalysisPrompt(language: String,
                             type: WorkspacePromptManager.AnalysisType,
                             variables: [String: String]) throws -> String {
        try promptManager.analysisPrompt(language: language, type: type, variables: variables)
    }
}
