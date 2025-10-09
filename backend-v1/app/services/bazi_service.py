"""
Bazi calculation service - adapted from existing code.
"""
import re
from datetime import date, datetime, timedelta
import math
from typing import Optional, Dict, Any, List, Tuple
from app.models.profiles import BaziChart, BaziPillar, BaziElements
from app.core.logging import get_logger

logger = get_logger(__name__)

# Constants from original calculator
GAN = ["甲","乙","丙","丁","戊","己","庚","辛","壬","癸"]
ZHI = ["子","丑","寅","卯","辰","巳","午","未","申","酉","戌","亥"]
ZHI_TO_INDEX0 = {z:i for i, z in enumerate(ZHI)}

# Five Elements mapping
GAN_TO_ELEMENT = {
    "甲": "wood", "乙": "wood",
    "丙": "fire", "丁": "fire",
    "戊": "earth", "己": "earth",
    "庚": "metal", "辛": "metal",
    "壬": "water", "癸": "water"
}

ZHI_TO_ELEMENT = {
    "子": "water", "丑": "earth", "寅": "wood", "卯": "wood",
    "辰": "earth", "巳": "fire", "午": "fire", "未": "earth",
    "申": "metal", "酉": "metal", "戌": "earth", "亥": "water"
}

YEAR_GAN_TO_M1_GAN = {
    "甲":"丙","己":"丙","乙":"戊","庚":"戊","丙":"庚",
    "辛":"庚","丁":"壬","壬":"壬","戊":"甲","癸":"甲",
}

DAY_GAN_TO_ZISHI_GAN_CLASSIC = {
    "甲":"丙","己":"丙","乙":"戊","庚":"戊","丙":"庚",
    "辛":"庚","丁":"壬","壬":"壬","戊":"甲","癸":"甲",
}

# 节气近似系数
JIE_COEFFS = {
    "立春":(4.6295,-1),"惊蛰":(6.3826,3),"清明":(5.59,15),"立夏":(6.318,7),
    "芒种":(6.5,7),"小暑":(7.928,8),"立秋":(8.35,8),"白露":(8.44,8),
    "寒露":(9.098,9),"立冬":(8.218,7),"大雪":(7.9,7),"小寒":(6.11,5),
}

JIE_TO_MONTH = {
    "立春":2,"惊蛰":3,"清明":4,"立夏":5,"芒种":6,"小暑":7,
    "立秋":8,"白露":9,"寒露":10,"立冬":11,"大雪":12,"小寒":1
}


class BaziService:
    """Service for Bazi calculations and analysis."""

    def calculate_bazi_chart(
        self,
        birth_date: date,
        birth_time: Optional[datetime] = None,
        longitude: Optional[float] = None
    ) -> BaziChart:
        """
        Calculate complete Bazi chart.

        Args:
            birth_date: Birth date
            birth_time: Birth time (optional)
            longitude: Longitude for solar time calculation (optional)

        Returns:
            Complete BaziChart
        """
        y, m, d = birth_date.year, birth_date.month, birth_date.day

        # Calculate pillars
        year_pillar, year_gan, year_zhi = self._year_pillar(y, m, d)
        month_pillar, month_gan, month_zhi, _ = self._month_pillar(y, m, d, year_gan)
        day_pillar, day_gan, day_zhi = self._day_pillar(y, m, d)

        # Calculate hour pillar if time provided
        hour_pillar = None
        hour_gan = None
        hour_zhi = None
        if birth_time and longitude is not None:
            hour_pillar, hour_gan, hour_zhi = self._hour_pillar(
                day_gan, birth_time, longitude
            )

        # Calculate five elements distribution
        elements = self._calculate_elements_distribution(
            year_gan, year_zhi, month_gan, month_zhi,
            day_gan, day_zhi, hour_gan, hour_zhi
        )

        # Create BaziChart
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

    def analyze_lucky_elements(self, chart: BaziChart) -> Tuple[List[str], List[str]]:
        """
        Analyze lucky and unlucky elements based on Bazi chart.

        Args:
            chart: BaziChart

        Returns:
            Tuple of (lucky_elements, unlucky_elements)
        """
        # Get day master element
        day_master_element = GAN_TO_ELEMENT[chart.day_master]

        # Simple rule-based analysis (can be enhanced)
        elements_strength = {
            "wood": chart.elements.wood,
            "fire": chart.elements.fire,
            "earth": chart.elements.earth,
            "metal": chart.elements.metal,
            "water": chart.elements.water
        }

        # Find dominant and weak elements
        avg_strength = 20.0  # Average should be 20% (100/5)
        strong_elements = [e for e, s in elements_strength.items() if s > avg_strength + 10]
        weak_elements = [e for e, s in elements_strength.items() if s < avg_strength - 10]

        # Lucky elements are typically those that balance the chart
        lucky_elements = []
        unlucky_elements = []

        # If day master is too strong, elements that control it are lucky
        if day_master_element in strong_elements:
            lucky_elements.extend(self._get_controlling_elements(day_master_element))
            unlucky_elements.append(day_master_element)
        # If day master is weak, elements that support it are lucky
        elif day_master_element in weak_elements:
            lucky_elements.append(day_master_element)
            lucky_elements.extend(self._get_supporting_elements(day_master_element))
            unlucky_elements.extend(self._get_controlling_elements(day_master_element))
        else:
            # Balanced, support weak elements
            lucky_elements.extend(weak_elements)
            unlucky_elements.extend(strong_elements)

        return lucky_elements, unlucky_elements

    def get_lucky_directions(self, lucky_elements: List[str]) -> List[str]:
        """
        Get lucky directions based on lucky elements.

        Args:
            lucky_elements: List of lucky elements

        Returns:
            List of lucky directions
        """
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

        return list(set(directions))  # Remove duplicates

    def get_lucky_colors(self, lucky_elements: List[str]) -> List[str]:
        """
        Get lucky colors based on lucky elements.

        Args:
            lucky_elements: List of lucky elements

        Returns:
            List of lucky colors
        """
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

    # Private methods (from original calculator.py)

    def _gregorian_to_jdn(self, y: int, m: int, d: int) -> int:
        """Convert Gregorian date to Julian Day Number."""
        a = (14 - m) // 12
        y2 = y + 4800 - a
        m2 = m + 12*a - 3
        return d + (153*m2 + 2)//5 + 365*y2 + y2//4 - y2//100 + y2//400 - 32045

    def _approx_jieqi_day(self, year: int, name: str) -> int:
        """Approximate Jieqi day."""
        C, fix = JIE_COEFFS[name]
        y = year - 1900
        return int((C + 0.2422 * y) - (y // 4)) + fix

    def _year_jie_dates(self, year: int):
        """Get Jieqi dates for a year."""
        return {
            k: date(year, JIE_TO_MONTH[k], self._approx_jieqi_day(year, k))
            for k in JIE_COEFFS
        }

    def _year_pillar(self, y: int, m: int, d: int):
        """Calculate year pillar."""
        lichun = self._year_jie_dates(y)["立春"]
        y_eval = y - 1 if date(y, m, d) < lichun else y
        idx60 = (y_eval - 1984) % 60
        return GAN[idx60 % 10] + ZHI[idx60 % 12], GAN[idx60 % 10], ZHI[idx60 % 12]

    def _month_pillar(self, y: int, m: int, d: int, year_gan: str):
        """Calculate month pillar."""
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
        """Calculate day pillar."""
        JDN_ANCHOR_1984_0202 = self._gregorian_to_jdn(1984, 2, 2)
        idx60 = (self._gregorian_to_jdn(y, m, d) - JDN_ANCHOR_1984_0202 + day_offset) % 60
        return GAN[idx60 % 10] + ZHI[idx60 % 12], GAN[idx60 % 10], ZHI[idx60 % 12]

    def _hour_pillar(self, day_gan: str, birth_time: datetime, longitude: float):
        """Calculate hour pillar with solar time adjustment."""
        # Convert to true solar time
        true_solar = self._standard_to_true_solar(birth_time, longitude)

        # Get hour branch
        hour_zhi = self._solar_time_to_zhi(true_solar.hour, true_solar.minute)

        # Calculate hour stem (popular method)
        gi = GAN.index(day_gan)
        zi0 = ZHI_TO_INDEX0[hour_zhi]
        hour_gan = GAN[(gi * 2 + zi0) % 10]

        return hour_gan + hour_zhi, hour_gan, hour_zhi

    def _standard_to_true_solar(self, dt_local: datetime, lon_deg: float) -> datetime:
        """Convert standard time to true solar time."""
        tz_hours = int(round(lon_deg / 15.0))
        lstm = 15.0 * tz_hours
        longitude_correction_min = 4.0 * (lon_deg - lstm)

        # Equation of time
        doy = (dt_local.date() - date(dt_local.year, 1, 1)).days + 1
        B = 2 * math.pi * (doy - 81) / 364.0
        eot = 229.18 * (0.000075 + 0.001868 * math.cos(B) - 0.032077 * math.sin(B)
                       - 0.014615 * math.cos(2*B) - 0.040849 * math.sin(2*B))

        delta = timedelta(minutes=longitude_correction_min + eot)
        return dt_local + delta

    def _solar_time_to_zhi(self, h: int, mi: int) -> str:
        """Convert solar time to earthly branch."""
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

    def _calculate_elements_distribution(
        self, year_gan, year_zhi, month_gan, month_zhi,
        day_gan, day_zhi, hour_gan, hour_zhi
    ) -> BaziElements:
        """Calculate five elements distribution."""
        elements_count = {"wood": 0, "fire": 0, "earth": 0, "metal": 0, "water": 0}

        # Count elements from stems and branches
        for gan in [year_gan, month_gan, day_gan]:
            if gan:
                elements_count[GAN_TO_ELEMENT[gan]] += 1

        for zhi in [year_zhi, month_zhi, day_zhi]:
            if zhi:
                elements_count[ZHI_TO_ELEMENT[zhi]] += 1

        if hour_gan:
            elements_count[GAN_TO_ELEMENT[hour_gan]] += 1
        if hour_zhi:
            elements_count[ZHI_TO_ELEMENT[hour_zhi]] += 1

        # Calculate percentages
        total = sum(elements_count.values()) or 1

        return BaziElements(
            wood=round(elements_count["wood"] / total * 100, 2),
            fire=round(elements_count["fire"] / total * 100, 2),
            earth=round(elements_count["earth"] / total * 100, 2),
            metal=round(elements_count["metal"] / total * 100, 2),
            water=round(elements_count["water"] / total * 100, 2)
        )

    def _get_supporting_elements(self, element: str) -> List[str]:
        """Get elements that support the given element."""
        support_map = {
            "wood": ["water"],  # Water nourishes wood
            "fire": ["wood"],   # Wood feeds fire
            "earth": ["fire"],  # Fire creates earth (ash)
            "metal": ["earth"], # Earth contains metal
            "water": ["metal"]  # Metal collects water
        }
        return support_map.get(element, [])

    def _get_controlling_elements(self, element: str) -> List[str]:
        """Get elements that control/weaken the given element."""
        control_map = {
            "wood": ["metal"],  # Metal cuts wood
            "fire": ["water"],  # Water extinguishes fire
            "earth": ["wood"],  # Wood depletes earth
            "metal": ["fire"],  # Fire melts metal
            "water": ["earth"]  # Earth absorbs water
        }
        return control_map.get(element, [])