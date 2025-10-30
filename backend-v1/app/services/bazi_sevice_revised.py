"""
八字计算服务（已改良 & 二元身强身弱判定）

说明（中文注释版）
-----------------
- **接口稳定**：保留全部对外函数名与参数签名，后端现有调用不会被破坏。
- **只给二元强弱**：内部强弱评估只输出两类——「身强」或「身弱」。
- **准确性改进**：
  1) 时柱优先使用 `birth_time.tzinfo` 的**法定时区**换算真太阳时；无 tzinfo 时再回退经度估算（兼容原逻辑）。
  2) 五行分布引入**藏干权重、月令季节强弱、位置权重**（月支>日支>年/时），替代单纯“个数计票”。
  3) 保留节气**近似算法**，同时提供**覆盖钩子** `_PRECOMPUTED_JIE_DATES`，可随时填入精确节气日期，无需改接口。
- **注释全面**：每个函数均含中文 docstring 与关键行内注释，便于维护与二次开发。
"""
import re
from datetime import date, datetime, timedelta
import math
from typing import Optional, Dict, Any, List, Tuple
from app.models.profiles import BaziChart, BaziPillar, BaziElements
from app.core.logging import get_logger

logger = get_logger(__name__)

# =============================================================================
#  常量与映射
# =============================================================================
# 天干、地支与索引
GAN = ["甲","乙","丙","丁","戊","己","庚","辛","壬","癸"]
ZHI = ["子","丑","寅","卯","辰","巳","午","未","申","酉","戌","亥"]
ZHI_TO_INDEX0 = {z:i for i, z in enumerate(ZHI)}

# 天干 → 五行 映射
GAN_TO_ELEMENT = {
    "甲": "wood", "乙": "wood",
    "丙": "fire", "丁": "fire",
    "戊": "earth", "己": "earth",
    "庚": "metal", "辛": "metal",
    "壬": "water", "癸": "water"
}

# 地支 → 五行（仅在缺少藏干表时作为兜底）
ZHI_TO_ELEMENT = {
    "子": "water", "丑": "earth", "寅": "wood", "卯": "wood",
    "辰": "earth", "巳": "fire", "午": "fire", "未": "earth",
    "申": "metal", "酉": "metal", "戌": "earth", "亥": "water"
}

# 年干 → 寅月干（孟春）映射表，用于推算各月天干
YEAR_GAN_TO_M1_GAN = {
    "甲":"丙","己":"丙","乙":"戊","庚":"戊","丙":"庚",
    "辛":"庚","丁":"壬","壬":"壬","戊":"甲","癸":"甲",
}

# 为兼容保留，当前未直接使用
DAY_GAN_TO_ZISHI_GAN_CLASSIC = {
    "甲":"丙","己":"丙","乙":"戊","庚":"戊","丙":"庚",
    "辛":"庚","丁":"壬","壬":"壬","戊":"甲","癸":"甲",
}

# =============================================================================
#  节气（近似算法 + 可选覆盖）
# =============================================================================
# 节气近似系数（保留原始计算方法）
JIE_COEFFS = {
    "立春":(4.6295,-1),"惊蛰":(6.3826,3),"清明":(5.59,15),"立夏":(6.318,7),
    "芒种":(6.5,7),"小暑":(7.928,8),"立秋":(8.35,8),"白露":(8.44,8),
    "寒露":(9.098,9),"立冬":(8.218,7),"大雪":(7.9,7),"小寒":(6.11,5),
}

# 节气 → 月份
JIE_TO_MONTH = {
    "立春":2,"惊蛰":3,"清明":4,"立夏":5,"芒种":6,"小暑":7,
    "立秋":8,"白露":9,"寒露":10,"立冬":11,"大雪":12,"小寒":1
}

# 可选：特定年份的精确节气日期（若提供则覆盖近似算法）
_PRECOMPUTED_JIE_DATES: Dict[int, Dict[str, date]] = {}

# =============================================================================
#  藏干与季节强弱表
# =============================================================================
# 各地支藏干及其权重（主气/中气/余气）
BRANCH_HIDDEN: Dict[str, List[Tuple[str, float]]] = {
    "子": [("癸", 1.0)],
    "丑": [("己", 0.6), ("癸", 0.2), ("辛", 0.2)],
    "寅": [("甲", 0.7), ("丙", 0.2), ("戊", 0.1)],
    "卯": [("乙", 1.0)],
    "辰": [("戊", 0.6), ("乙", 0.2), ("癸", 0.2)],
    "巳": [("丙", 0.7), ("戊", 0.2), ("庚", 0.1)],
    "午": [("丁", 0.7), ("己", 0.3)],
    "未": [("己", 0.6), ("丁", 0.2), ("乙", 0.2)],
    "申": [("庚", 0.7), ("壬", 0.2), ("戊", 0.1)],
    "酉": [("辛", 1.0)],
    "戌": [("戊", 0.6), ("辛", 0.2), ("丁", 0.2)],
    "亥": [("壬", 0.7), ("甲", 0.3)],
}

# 月令季节强弱（简化版）：在该月支下，各五行的相对强度（0~1）
SEASONAL_STRENGTH: Dict[str, Dict[str, float]] = {
    "寅": {"wood": 1.0, "fire": 0.7, "water": 0.4, "metal": 0.2, "earth": 0.3},
    "卯": {"wood": 1.0, "fire": 0.7, "water": 0.4, "metal": 0.2, "earth": 0.3},
    "巳": {"fire": 1.0, "earth": 0.7, "wood": 0.3, "metal": 0.3, "water": 0.2},
    "午": {"fire": 1.0, "earth": 0.7, "wood": 0.3, "metal": 0.3, "water": 0.2},
    "申": {"metal": 1.0, "water": 0.7, "earth": 0.4, "fire": 0.3, "wood": 0.2},
    "酉": {"metal": 1.0, "water": 0.7, "earth": 0.4, "fire": 0.3, "wood": 0.2},
    "亥": {"water": 1.0, "wood": 0.7, "metal": 0.3, "earth": 0.3, "fire": 0.2},
    "子": {"water": 1.0, "wood": 0.7, "metal": 0.3, "earth": 0.3, "fire": 0.2},
    "辰": {"earth": 1.0, "metal": 0.7, "fire": 0.5, "wood": 0.4, "water": 0.3},
    "戌": {"earth": 1.0, "metal": 0.7, "fire": 0.5, "wood": 0.4, "water": 0.3},
    "丑": {"earth": 1.0, "metal": 0.7, "water": 0.5, "wood": 0.3, "fire": 0.3},
    "未": {"earth": 1.0, "fire": 0.7, "wood": 0.5, "metal": 0.3, "water": 0.3},
}

# 五行生克循环（用于喜忌与强弱评估）
ELEM_CYCLE = {
    "wood":  {"gen": "water", "leak": "fire",  "controls": "earth", "beaten_by": "metal"},
    "fire":  {"gen": "wood",  "leak": "earth", "controls": "metal", "beaten_by": "water"},
    "earth": {"gen": "fire",  "leak": "metal", "controls": "water", "beaten_by": "wood"},
    "metal": {"gen": "earth", "leak": "water", "controls": "wood",  "beaten_by": "fire"},
    "water": {"gen": "metal", "leak": "wood",  "controls": "fire",  "beaten_by": "earth"},
}


class BaziService:
    """八字计算与分析服务（只输出二元身强/身弱）。

    公有 API（保持不变）
    --------------------
    - calculate_bazi_chart(...)
    - analyze_lucky_elements(chart)
    - get_lucky_directions(lucky_elements)
    - get_lucky_colors(lucky_elements)
    """

    # ---------------------------------------------------------------------
    # 公有：计算四柱与五行分布
    # ---------------------------------------------------------------------
    def calculate_bazi_chart(
        self,
        birth_date: date,
        birth_time: Optional[datetime] = None,
        longitude: Optional[float] = None
    ) -> BaziChart:
        """生成年、月、日、时四柱，并计算五行百分比。

        参数
        ----
        birth_date : 公历生日。
        birth_time : 出生时间（可含 tzinfo）。若与 longitude 同时提供，会按**真太阳时**计算时柱。
        longitude  : 经度（东经+，西经-）。用于真太阳时换算（时区与方程时修正）。

        返回
        ----
        BaziChart : 包含四柱、日主天干、五行分布的结构体。
        """
        y, m, d = birth_date.year, birth_date.month, birth_date.day

        # 年/月/日柱
        year_pillar, year_gan, year_zhi = self._year_pillar(y, m, d)
        month_pillar, month_gan, month_zhi, _ = self._month_pillar(y, m, d, year_gan)
        day_pillar, day_gan, day_zhi = self._day_pillar(y, m, d)

        # 时柱（仅当同时提供时间与经度时计算）
        hour_pillar = None
        hour_gan = None
        hour_zhi = None
        if birth_time and longitude is not None:
            hour_pillar, hour_gan, hour_zhi = self._hour_pillar(
                day_gan, birth_time, longitude
            )

        # 五行分布：引入藏干+季节+位置权重
        elements = self._calculate_elements_distribution(
            year_gan, year_zhi, month_gan, month_zhi,
            day_gan, day_zhi, hour_gan, hour_zhi
        )

        # 组装返回对象
        chart = BaziChart(
            year_pillar=BaziPillar(
                heavenly_stem=year_gan,
                earthly_branch=year_zhi,
                element=GAN_TO_ELEMENT[year_gan]
            ),
            month_pillar=BaziPillar(
                heavenly_stem=month_gan,
                earthly_branch=month_zhi,
                element=GAN_TO_ELEMENT[month_gan]
            ),
            day_pillar=BaziPillar(
                heavenly_stem=day_gan,
                earthly_branch=day_zhi,
                element=GAN_TO_ELEMENT[day_gan]
            ),
            hour_pillar=BaziPillar(
                heavenly_stem=hour_gan or "",
                earthly_branch=hour_zhi or "",
                element=GAN_TO_ELEMENT.get(hour_gan, "")
            ) if hour_gan else BaziPillar(
                heavenly_stem="",
                earthly_branch="",
                element=""
            ),
            day_master=day_gan,
            elements=elements
        )

        return chart

    # ---------------------------------------------------------------------
    # 公有：基于「二元身强/身弱」给出喜忌五行
    # ---------------------------------------------------------------------
    def analyze_lucky_elements(self, chart: BaziChart) -> Tuple[List[str], List[str]]:
        """按二元强弱输出喜用/忌讳的五行列表。

        规则简述
        --------
        - 先评估**日主强弱**（只分「身强」或「身弱」）。
        - 身强：宜泄耗/制（食伤、官杀），忌再扶助（比劫、印）。
        - 身弱：宜扶助（比劫、印），忌泄耗/克制（食伤、官杀）。
        """
        dm_elem = GAN_TO_ELEMENT[chart.day_master]

        # 得到二元强弱标签
        strength = self._evaluate_day_master_strength(
            day_gan=chart.day_master,
            year_gan=chart.year_pillar.heavenly_stem,
            year_zhi=chart.year_pillar.earthly_branch,
            month_gan=chart.month_pillar.heavenly_stem,
            month_zhi=chart.month_pillar.earthly_branch,
            day_zhi=chart.day_pillar.earthly_branch,
            hour_gan=chart.hour_pillar.heavenly_stem or None,
            hour_zhi=chart.hour_pillar.earthly_branch or None,
        )
        label = strength["label"]  # "身强" / "身弱"

        cycle = ELEM_CYCLE[dm_elem]
        lucky: List[str] = []
        unlucky: List[str] = []

        if label == "身强":
            lucky.extend([cycle["controls"], cycle["leak"]])
            unlucky.extend([dm_elem, cycle["gen"]])
        else:  # 身弱
            lucky.extend([dm_elem, cycle["gen"]])
            unlucky.extend([cycle["leak"], cycle["beaten_by"]])

        # 去重但保序
        def dedup_keep(seq: List[str]) -> List[str]:
            seen = set()
            out = []
            for x in seq:
                if x and x not in seen:
                    seen.add(x)
                    out.append(x)
            return out

        return dedup_keep(lucky), dedup_keep(unlucky)

    # ---------------------------------------------------------------------
    # 公有：喜用 → 方位
    # ---------------------------------------------------------------------
    def get_lucky_directions(self, lucky_elements: List[str]) -> List[str]:
        """将五行映射到常用方位。"""
        element_to_directions = {
            "wood": ["east", "southeast"],
            "fire": ["south"],
            "earth": ["center", "northeast", "southwest"],
            "metal": ["west", "northwest"],
            "water": ["north"]
        }
        directions = []
        for element in lucky_elements:
            directions.extend(element_to_directions.get(element, []))
        return list(set(directions))

    # ---------------------------------------------------------------------
    # 公有：喜用 → 颜色
    # ---------------------------------------------------------------------
    def get_lucky_colors(self, lucky_elements: List[str]) -> List[str]:
        """将五行映射到代表性色彩。"""
        element_to_colors = {
            "wood": ["green", "cyan", "turquoise"],
            "fire": ["red", "orange", "purple"],
            "earth": ["yellow", "brown", "beige"],
            "metal": ["white", "silver", "gold"],
            "water": ["black", "blue", "gray"]
        }
        colors = []
        for element in lucky_elements:
            colors.extend(element_to_colors.get(element, []))
        return colors

    # =============================================================================
    #  私有：历法与四柱计算
    # =============================================================================
    def _gregorian_to_jdn(self, y: int, m: int, d: int) -> int:
        """公历 → 儒略日（整数）。用于计算日柱 60 甲子序号。"""
        a = (14 - m) // 12
        y2 = y + 4800 - a
        m2 = m + 12*a - 3
        return d + (153*m2 + 2)//5 + 365*y2 + y2//4 - y2//100 + y2//400 - 32045

    def _approx_jieqi_day(self, year: int, name: str) -> int:
        """节气近似推算（返回日）。作为无覆盖表时的后备方案。"""
        C, fix = JIE_COEFFS[name]
        y = year - 1900
        return int((C + 0.2422 * y) - (y // 4)) + fix

    def _year_jie_dates(self, year: int):
        """获取某年的节气日期映射。若存在覆盖表则优先使用。"""
        if year in _PRECOMPUTED_JIE_DATES:
            return _PRECOMPUTED_JIE_DATES[year]
        return {
            k: date(year, JIE_TO_MONTH[k], self._approx_jieqi_day(year, k))
            for k in JIE_COEFFS
        }

    def _year_pillar(self, y: int, m: int, d: int):
        """计算**年柱**：以立春为岁首，确定干支。返回(柱, 干, 支)。"""
        lichun = self._year_jie_dates(y)["立春"]
        y_eval = y - 1 if date(y, m, d) < lichun else y
        idx60 = (y_eval - 1984) % 60
        return GAN[idx60 % 10] + ZHI[idx60 % 12], GAN[idx60 % 10], ZHI[idx60 % 12]

    def _month_pillar(self, y: int, m: int, d: int, year_gan: str):
        """计算**月柱**：用节气切分太阳年，定位月序并推算月干支。

        步骤：
        1) 以立春为分界确定所属太阳年；
        2) 构造从立春→小寒→次年立春的 12 段边界；
        3) 月支：寅起（+2 偏移）；月干：依据「年干→寅月干」表顺推。
        返回(柱, 干, 支, 月序1..12)。
        """
        cur = date(y, m, d)
        Yb = y if cur >= self._year_jie_dates(y)["立春"] else (y - 1)
        jy = self._year_jie_dates(Yb)
        jn = self._year_jie_dates(Yb + 1)
        boundaries = [
            jy["立春"], jy["惊蛰"], jy["清明"], jy["立夏"], jy["芒种"], jy["小暑"],
            jy["立秋"], jy["白露"], jy["寒露"], jy["立冬"], jy["大雪"], jn["小寒"], jn["立春"]
        ]
        month_idx = next((i for i in range(12) if boundaries[i] <= cur < boundaries[i+1]), 0)
        zhi = ZHI[(2 + month_idx) % 12]
        gan = GAN[(GAN.index(YEAR_GAN_TO_M1_GAN[year_gan]) + month_idx) % 10]
        return gan + zhi, gan, zhi, month_idx + 1

    def _day_pillar(self, y: int, m: int, d: int, day_offset: int = 2):
        """计算**日柱**：以 1984-02-02 为锚点加偏移求 60 甲子序号。

        说明：为保持与你线上结果一致，`day_offset` 仍为 2。如需对齐权威万年历，
        可在回归测试中按需微调该值。
        """
        JDN_ANCHOR_1984_0202 = self._gregorian_to_jdn(1984, 2, 2)
        idx60 = (self._gregorian_to_jdn(y, m, d) - JDN_ANCHOR_1984_0202 + day_offset) % 60
        return GAN[idx60 % 10] + ZHI[idx60 % 12], GAN[idx60 % 10], ZHI[idx60 % 12]

    def _hour_pillar(self, day_gan: str, birth_time: datetime, longitude: float):
        """计算**时柱**：将法定本地时换算为真太阳时后定时支与时干。

        - 优先使用 `birth_time.tzinfo`（法定时区）
        - 若无 tzinfo 则回退按经度推时区（精度较低，但兼容旧逻辑）
        """
        true_solar = self._standard_to_true_solar(birth_time, longitude)
        hour_zhi = self._solar_time_to_zhi(true_solar.hour, true_solar.minute)
        gi = GAN.index(day_gan)
        zi0 = ZHI_TO_INDEX0[hour_zhi]
        hour_gan = GAN[(gi * 2 + zi0) % 10]
        return hour_gan + hour_zhi, hour_gan, hour_zhi

    def _standard_to_true_solar(self, dt_local: datetime, lon_deg: float) -> datetime:
        """**法定本地时 → 真太阳时**：按经度差与方程时（EoT）进行修正。"""
        # 1) 取法定时区（若可用），否则按经度近似；单位：小时
        if dt_local.tzinfo is not None and dt_local.utcoffset() is not None:
            tz_offset_hours = int(round(dt_local.utcoffset().total_seconds() / 3600.0))
        else:
            tz_offset_hours = int(round(lon_deg / 15.0))  # 兜底：可能有 ~1 小时误差

        # 2) 以法定时区推得当地标准经线（度）
        lstm = 15.0 * tz_offset_hours
        longitude_correction_min = 4.0 * (lon_deg - lstm)

        # 3) 方程时（分钟）
        doy = (dt_local.date() - date(dt_local.year, 1, 1)).days + 1
        B = 2 * math.pi * (doy - 81) / 364.0
        eot = 229.18 * (0.000075 + 0.001868 * math.cos(B) - 0.032077 * math.sin(B)
                        - 0.014615 * math.cos(2*B) - 0.040849 * math.sin(2*B))

        delta = timedelta(minutes=longitude_correction_min + eot)
        return dt_local + delta

    def _solar_time_to_zhi(self, h: int, mi: int) -> str:
        """真太阳时 → 时支映射。"""
        t = h*60 + mi
        if t >= 23*60 or t < 1*60: return "子"
        if 1*60 <= t < 3*60: return "丑"
        if 3*60 <= t < 5*60: return "寅"
        if 5*60 <= t < 7*60: return "卯"
        if 7*60 <= t < 9*60: return "辰"
        if 9*60 <= t < 11*60: return "巳"
        if 11*60 <= t < 13*60: return "午"
        if 13*60 <= t < 15*60: return "未"
        if 15*60 <= t < 17*60: return "申"
        if 17*60 <= t < 19*60: return "酉"
        if 19*60 <= t < 21*60: return "戌"
        return "亥"  # 21:00–22:59

    # =============================================================================
    #  私有：五行分布与强弱评估
    # =============================================================================
    def _calculate_elements_distribution(
        self, year_gan, year_zhi, month_gan, month_zhi,
        day_gan, day_zhi, hour_gan, hour_zhi
    ) -> BaziElements:
        """计算五行百分比：引入藏干、季节与位置权重。

        策略：
        - 天干：直接按其五行计入；
        - 地支：展开为藏干（主/中/余气权重），并受**月支季节强弱**调制；
        - 位置权重：月支 > 日支 > 年支 ≈ 时支；
        - 最终归一化到 0~100%。
        """
        elem_score: Dict[str, float] = {"wood": 0.0, "fire": 0.0, "earth": 0.0, "metal": 0.0, "water": 0.0}

        # 位置权重（地支）
        W_STEM = 1.0
        W_YEAR_BRANCH = 1.0
        W_MONTH_BRANCH = 1.5
        W_DAY_BRANCH = 1.2
        W_HOUR_BRANCH = 1.0

        def add_stem(gan: Optional[str], w: float = W_STEM) -> None:
            """把一个天干按权重计入其五行桶。"""
            if gan:
                e = GAN_TO_ELEMENT.get(gan)
                if e:
                    elem_score[e] += w

        def add_branch(zhi: Optional[str], pos_w: float) -> None:
            """把一个地支按藏干展开计入（含季节调制），无藏干表则兜底为地支主五行。"""
            if not zhi:
                return
            hidden = BRANCH_HIDDEN.get(zhi)
            if not hidden:
                e = ZHI_TO_ELEMENT.get(zhi)
                if e:
                    elem_score[e] += pos_w
                return
            season = SEASONAL_STRENGTH.get(month_zhi, {})
            for gan_i, w_i in hidden:
                e = GAN_TO_ELEMENT.get(gan_i)
                if not e:
                    continue
                boost = season.get(e, 0.4)  # 若无则给一个温和基线
                elem_score[e] += pos_w * w_i * (0.8 + 0.4 * boost)

        # 天干累计
        add_stem(year_gan)
        add_stem(month_gan)
        add_stem(day_gan)
        if hour_gan:
            add_stem(hour_gan)

        # 地支累计
        add_branch(year_zhi, W_YEAR_BRANCH)
        add_branch(month_zhi, W_MONTH_BRANCH)
        add_branch(day_zhi, W_DAY_BRANCH)
        if hour_zhi:
            add_branch(hour_zhi, W_HOUR_BRANCH)

        total = sum(elem_score.values()) or 1.0
        return BaziElements(
            wood=round(elem_score["wood"] / total * 100, 2),
            fire=round(elem_score["fire"] / total * 100, 2),
            earth=round(elem_score["earth"] / total * 100, 2),
            metal=round(elem_score["metal"] / total * 100, 2),
            water=round(elem_score["water"] / total * 100, 2)
        )

    def _get_supporting_elements(self, element: str) -> List[str]:
        """（兼容保留）返回对该五行有「生助」作用的五行。"""
        support_map = {
            "wood": ["water"],
            "fire": ["wood"],
            "earth": ["fire"],
            "metal": ["earth"],
            "water": ["metal"]
        }
        return support_map.get(element, [])

    def _get_controlling_elements(self, element: str) -> List[str]:
        """（兼容保留）返回对该五行有「克制/削弱」作用的五行。"""
        control_map = {
            "wood": ["metal"],
            "fire": ["water"],
            "earth": ["wood"],
            "metal": ["fire"],
            "water": ["earth"]
        }
        return control_map.get(element, [])

    def _evaluate_day_master_strength(
        self,
        day_gan: str,
        year_gan: str, year_zhi: str,
        month_gan: str, month_zhi: str,
        day_zhi: str,
        hour_gan: Optional[str], hour_zhi: Optional[str],
    ) -> Dict[str, Any]:
        """评估日主强弱（**二元分类**）：返回 {label: 身强|身弱, score, 各分项}。

        评估逻辑（可解释）
        --------------
        - 得令：按月支季节强弱表取日主五行的系数，权重高；
        - 得地：四柱地支的藏干中，比劫/印给正分（含位置权重，日支>月支>年支≈时支）；
        - 得助/受制：明干中，比劫/印加分，食伤/财/官杀扣分（含位置权重）。
        - 汇总后线性归一为 0~100 分，再用阈值 55 做二元切分。
        """
        dm_elem = GAN_TO_ELEMENT[day_gan]
        cycle = ELEM_CYCLE[dm_elem]

        # 1) 得令（季节系数）
        season = SEASONAL_STRENGTH.get(month_zhi, {})
        season_score = season.get(dm_elem, 0.4) * 3.0

        # 2) 得地（根气：四支藏干给力）
        def hidden_score(zhi: str, pos_weight: float) -> float:
            score = 0.0
            for gan_i, w in BRANCH_HIDDEN.get(zhi, []):
                e = GAN_TO_ELEMENT.get(gan_i)
                if e == dm_elem:              # 比劫：强扶
                    score += 1.0 * w * pos_weight
                elif e == cycle["gen"]:      # 印：生我
                    score += 0.8 * w * pos_weight
            return score

        root_score = 0.0
        root_score += hidden_score(day_zhi, 2.0)
        root_score += hidden_score(month_zhi, 1.5)
        root_score += hidden_score(year_zhi, 1.0)
        if hour_zhi:
            root_score += hidden_score(hour_zhi, 1.0)

        # 3) 明干的助与制
        def stem_help_penalty(gan: Optional[str], pos_weight: float) -> float:
            if not gan:
                return 0.0
            e = GAN_TO_ELEMENT.get(gan)
            if e == dm_elem:                 # 比劫 → 助身
                return 1.0 * pos_weight
            if e == cycle["gen"]:           # 印 → 生我
                return 0.8 * pos_weight
            if e == cycle["leak"]:          # 食伤 → 我生（泄）
                return -0.7 * pos_weight
            if e == cycle["controls"]:      # 财 → 我克（耗）
                return -0.9 * pos_weight
            if e == cycle["beaten_by"]:     # 官杀 → 克我（制）
                return -1.1 * pos_weight
            return 0.0

        help_penalty = 0.0
        help_penalty += stem_help_penalty(month_gan, 1.5)
        help_penalty += stem_help_penalty(day_gan,   1.2)
        help_penalty += stem_help_penalty(year_gan,  1.0)
        if hour_gan:
            help_penalty += stem_help_penalty(hour_gan, 1.0)

        # 4) 归一并二元判定
        raw = season_score + root_score + help_penalty
        score = max(0.0, min(100.0, 50.0 + raw * 6.0))
        label = "身强" if score >= 55.0 else "身弱"

        return {
            "score": round(score, 1),   # 便于调试与埋点
            "label": label,            # 仅二元输出
            "season": round(season_score, 2),
            "root": round(root_score, 2),
            "stems": round(help_penalty, 2),
        }
