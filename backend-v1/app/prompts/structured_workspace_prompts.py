"""
Structured workspace prompts for different day master elements.
(Refined poetic-humanistic version; IMAGE-based input)
"""
from typing import Dict, Optional, List, Tuple
from .base import PromptTemplate


# ============================================================
#  天干与五行映射
# ============================================================

DAY_MASTER_TO_ELEMENT = {
    "甲": "wood", "乙": "wood",
    "丙": "fire", "丁": "fire",
    "戊": "earth", "己": "earth",
    "庚": "metal", "辛": "metal",
    "壬": "water", "癸": "water",
    "wood": "wood", "fire": "fire",
    "earth": "earth", "metal": "metal",
    "water": "water",
}


def normalize_day_master_element(value: str) -> str:
    """Normalize day master input (天干或五行英文) to template key."""
    if not value:
        return ""
    return DAY_MASTER_TO_ELEMENT.get(value.strip().lower(), value.strip().lower())


# ============================================================
#  核心生成函数
# ============================================================

def _format_template(
    stems_label: str,
    element_focus: str,
    liuhe_pairs: List[Tuple[str, str]],
    liuchong_pairs: List[Tuple[str, str]],
) -> str:
    """
    Helper to format poetic yet grounded Feng Shui prompt.
    Now adapted for IMAGE input: the model should observe the uploaded image directly.
    """
    liuhe_text = "\n".join([f"    - {pair}：{desc}" for pair, desc in liuhe_pairs])
    liuchong_text = "\n".join([f"    - {pair}：{desc}" for pair, desc in liuchong_pairs])

    return f"""你是一位温和而洞察入微的风水顾问，气质近似 INFJ。  
你只依据以下输入进行细致观察：
- 日主：${{day_master_element}}（{stems_label}）
- 用户性别：${{user_gender}}
- 工位朝向：${{desk_orientation}}
- 工位图像：${{workspace_image}}（工位桌面的正前方和面向方位为朱雀，左侧桌面以及座位左面的区域为青龙，右侧桌面以及座位右面的区域为白虎，背后区域为玄武）

请以有温度的语言书写分析，让人感到被理解，而非被评判。  
文风要带有象征与节奏感，像一位懂空间与人心的诗人。  
{element_focus}

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

每一象都需“先写亮点，再写隐忧”，并结合 ${{user_gender}} 的角色（如职场身份、家庭关系或情感期待），  
解释这种空间状态如何折射他们的内在节奏与人际能量流。

---

### 二、地支气场
工位面向的方位是${{desk_orientation}}，请你把工位周围的方向映射至十二地支：
北=子、东北=丑/寅、东=卯、东南=辰/巳、南=午、西南=未/申、西=酉、西北=戌/亥。  
观察物件的分布与呼应，判断是否形成“六合”或“六冲”：  
例如——子位水缸与午位火源为子午冲；辰位绿植与戌位蜡烛为辰戌冲。  
合为气顺、冲为气逆，先说明方位证据短句（比如是“子位见水杯，午位见红色灯，形成子午冲”，再请说明其象征与影响。

---

### 三、合冲笔记
以细腻语气描述是否观察到以下组合：

- **六合**：若出现下列呼应，请写出触发方位及积极意义；若未见，请写“未见对应迹象”。
{liuhe_text}

- **六冲**：若出现下列对冲，请说明触发方位与潜在风险；若未见，请写“未见对应迹象”。
{liuchong_text}

---

### 输出格式
请严格返回合法 JSON，不得添加额外说明或 Markdown。
结构如下：
{{
    "si_xiang_problems": {{
        "qinglong": "...",
        "baihu": "...",
        "zhuque": "...",
        "xuanwu": "..."
    }},
    "earthly_branch_analysis": {{
        "liu_he": "...",
        "liu_chong": "..."
    }}
}}
"""


# ============================================================
#  五行模板定义
# ============================================================

def build_structured_workspace_prompts() -> Dict[str, PromptTemplate]:
    """Create poetic structured JSON prompts for each day master element (image-based)."""
    templates: Dict[str, PromptTemplate] = {}

    # 木日主
    templates["wood"] = PromptTemplate(
        template=_format_template(
            stems_label="甲/乙木",
            element_focus="木日主如树，重生长、讲秩序。青龙代表枝叶向外舒展，白虎是修剪的刀，朱雀是花，玄武是根。木人若左右平衡，则思想与行动皆能成林。",
            liuhe_pairs=[
                ("戌卯合", "合作有成，表达顺畅，旧友或合作关系回温"),
                ("寅亥合", "志同道合的支持，缓解焦虑与孤立感"),
                ("子丑合", "资源合并，男性得财，家庭稳定"),
                ("辰酉合", "晋升与薪酬双利，伴随金钱投入"),
                ("巳申合", "上级赏识与女性情缘并行，沟通增多"),
                ("午未合", "财运与情感双收，思维灵动"),
            ],
            liuchong_pairs=[
                ("子午冲", "情绪波动，资源不稳，女性需关心生理健康"),
                ("未丑冲", "财库受扰，男性易陷情绪低谷"),
                ("寅申冲", "出行与人际纷争多，女性易遭误解"),
                ("卯酉冲", "感情与合作受阻，警惕口舌纷争"),
                ("辰戌冲", "得失并存，男性声誉易受冲击"),
                ("巳亥冲", "事业与家庭拉扯，情绪起伏大"),
            ],
        ),
        variables=["day_master_element", "desk_orientation", "workspace_image", "user_gender"],
    )

    # 火日主
    templates["fire"] = PromptTemplate(
        template=_format_template(
            stems_label="丙/丁火",
            element_focus="火日主如焰，明朗而热切。朱雀是火的核心，青龙助燃灵感，白虎决定火势方向，玄武令热情不致失控。火旺而稳，则温暖众人。",
            liuhe_pairs=[
                ("卯戌合", "资源整合、上司扶持，助力火势正旺"),
                ("寅亥合", "职位上升、女性感情顺畅，权力得承认"),
                ("子丑合", "财库稳固，灵感化收益"),
                ("辰酉合", "偏财与兴趣并进，男性桃花温和有助"),
                ("巳申合", "合作激发创意，虽有摩擦终见成效"),
                ("午未合", "人际和缓、情绪舒展"),
            ],
            liuchong_pairs=[
                ("子午冲", "女性感情与职场波动，需控制情绪过热"),
                ("未丑冲", "压力骤升，身体虚耗，女性生殖健康需留意"),
                ("寅申冲", "财运起伏，男性情感易起矛盾"),
                ("卯酉冲", "投资误判，男性需警惕烂桃花"),
                ("辰戌冲", "过度投入导致疲惫，女性健康受影响"),
                ("巳亥冲", "职场震荡或流言，需稳住节奏"),
            ],
        ),
        variables=["day_master_element", "desk_orientation", "workspace_image", "user_gender"],
    )

    # 土日主
    templates["earth"] = PromptTemplate(
        template=_format_template(
            stems_label="戊/己土",
            element_focus="土日主如原野，重承载与秩序。青龙与白虎如护城墙，朱雀为沟通之门，玄武是山之根。土稳，则众事安。",
            liuhe_pairs=[
                ("卯戌合", "合作稳固，体制内机缘增"),
                ("寅亥合", "晋升与情感并进，上司赏识"),
                ("子丑合", "合作得财，兄弟助力"),
                ("辰酉合", "友情修复，压力化解"),
                ("巳申合", "权力增长伴随责任"),
                ("午未合", "同盟结交，人际和缓"),
            ],
            liuchong_pairs=[
                ("子午冲", "财运冲击，男性易遇短暂情缘"),
                ("未丑冲", "合作摩擦，健康受损"),
                ("寅申冲", "女性受压，职场受限"),
                ("卯酉冲", "感情易生第三者，合作波动"),
                ("辰戌冲", "金钱与声誉之争"),
                ("巳亥冲", "奔波劳累，收益不稳"),
            ],
        ),
        variables=["day_master_element", "desk_orientation", "workspace_image", "user_gender"],
    )

    # 金日主
    templates["metal"] = PromptTemplate(
        template=_format_template(
            stems_label="庚/辛金",
            element_focus="金日主如刃，重秩序与锋芒。青龙与白虎为双刃，朱雀为舞台，玄武为鞘。金要懂收放，锋利方可成器。",
        liuhe_pairs=[
                ("卯戌合", "资源整合、男性感情温润"),
                ("寅亥合", "灵感与偏财并进"),
                ("子丑合", "权力放大，女性得照拂"),
                ("辰酉合", "伙伴互补，关系修复"),
                ("巳申合", "竞争促成长"),
                ("午未合", "职位与情感同步提升"),
            ],
            liuchong_pairs=[
                ("子午冲", "女性感情与合作受阻，工作/上下级关系受压制"),
                ("未丑冲", "资产震荡、家庭摇摆"),
                ("寅申冲", "男性感情动荡，合伙猜疑"),
                ("卯酉冲", "财运反复，需防冲动投资"),
                ("辰戌冲", "小人干扰，名誉波动"),
                ("巳亥冲", "女性事业受阻，或调岗转向"),
            ],
        ),
        variables=["day_master_element", "desk_orientation", "workspace_image", "user_gender"],
    )

    # 水日主
    templates["water"] = PromptTemplate(
        template=_format_template(
            stems_label="壬/癸水",
            element_focus="水日主如流，重灵动与通达。朱雀为远景，青龙为灵感，白虎为执行，玄武为承托。若水得其道，则情绪与思维并流。",
            liuhe_pairs=[
                ("卯戌合", "晋升与感情并进，女性得益"),
                ("寅亥合", "益友扶持，孤独感消融"),
                ("子丑合", "职位上升，男性突破限制"),
                ("辰酉合", "资源流通，女性获助"),
                ("巳申合", "出行得机缘，事业合财兼得，合伙合作，男性桃花运提升，女性财运提升"),
                ("午未合", "职场与感情双向突破"),
            ],
            liuchong_pairs=[
                ("子午冲", "职位变动，女性感情紧张"),
                ("未丑冲", "人际失衡，易起利益纷争"),
                ("寅申冲", "奔波劳累，身心疲惫"),
                ("卯酉冲", "家庭与资产波动"),
                ("辰戌冲", "官司与口舌之忧"),
                ("巳亥冲", "男性感情多变，易生竞争"),
            ],
        ),
        variables=["day_master_element", "desk_orientation", "workspace_image", "user_gender"],
    )

    return templates


# ============================================================
#  Prompt 生成接口函数（
# ============================================================

def generate_structured_workspace_prompt(
    day_master_element: str,
    desk_orientation: str,
    workspace_image: str,
    user_gender: str,
    templates: Optional[Dict[str, PromptTemplate]] = None,
) -> str:
    """
    Generate structured workspace prompt text directly (IMAGE-based).

    Args:
        day_master_element: 天干或五行关键字
        desk_orientation: 工位朝向描述
        workspace_image: 工位图片引用（如 gs:// / https:// / [INLINE_IMAGE] 占位）
        user_gender: 用户性别
        templates: Optional cache of templates to reuse

    Returns:
        Prompt string enforcing JSON output for the given element
    """
    normalized = normalize_day_master_element(day_master_element)
    template_map = templates or build_structured_workspace_prompts()
    if normalized not in template_map:
        raise ValueError(f"Unsupported day master element: {day_master_element}")
    return template_map[normalized].format(
        day_master_element=day_master_element,
        desk_orientation=desk_orientation,
        workspace_image=workspace_image,
        user_gender=user_gender,
    )
