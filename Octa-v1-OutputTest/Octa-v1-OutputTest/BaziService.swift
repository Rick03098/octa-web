import Foundation

enum BaziError: Error {
    case invalidDateComponents
}

struct BaziPillar: Codable {
    let heavenlyStem: String
    let earthlyBranch: String
    let element: String
}

struct BaziElements: Codable {
    let wood: Double
    let fire: Double
    let earth: Double
    let metal: Double
    let water: Double
}

struct BaziChart: Codable {
    let yearPillar: BaziPillar
    let monthPillar: BaziPillar
    let dayPillar: BaziPillar
    let hourPillar: BaziPillar
    let dayMaster: String
    let elements: BaziElements
}

struct BirthInfo {
    let year: Int
    let month: Int
    let day: Int
    let hour: Int?
    let minute: Int?
    let timeZone: TimeZone?
    let longitude: Double?

    init(year: Int,
         month: Int,
         day: Int,
         hour: Int? = nil,
         minute: Int? = nil,
         timeZone: TimeZone? = nil,
         longitude: Double? = nil) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.timeZone = timeZone
        self.longitude = longitude
    }
}

final class BaziService {
    private static let gan = ["甲","乙","丙","丁","戊","己","庚","辛","壬","癸"]
    private static let zhi = ["子","丑","寅","卯","辰","巳","午","未","申","酉","戌","亥"]
    private static let zhiToIndex: [String: Int] = {
        var dict: [String: Int] = [:]
        for (idx, value) in zhi.enumerated() {
            dict[value] = idx
        }
        return dict
    }()

    private static let ganToElement: [String: String] = [
        "甲": "wood", "乙": "wood",
        "丙": "fire", "丁": "fire",
        "戊": "earth", "己": "earth",
        "庚": "metal", "辛": "metal",
        "壬": "water", "癸": "water"
    ]

    private static let zhiToElement: [String: String] = [
        "子": "water", "丑": "earth", "寅": "wood", "卯": "wood",
        "辰": "earth", "巳": "fire", "午": "fire", "未": "earth",
        "申": "metal", "酉": "metal", "戌": "earth", "亥": "water"
    ]

    private static let yearGanToM1Gan: [String: String] = [
        "甲":"丙","己":"丙","乙":"戊","庚":"戊","丙":"庚",
        "辛":"庚","丁":"壬","壬":"壬","戊":"甲","癸":"甲"
    ]

    private static let jieCoeffs: [String: (Double, Int)] = [
        "立春":(4.6295,-1),"惊蛰":(6.3826,3),"清明":(5.59,15),"立夏":(6.318,7),
        "芒种":(6.5,7),"小暑":(7.928,8),"立秋":(8.35,8),"白露":(8.44,8),
        "寒露":(9.098,9),"立冬":(8.218,7),"大雪":(7.9,7),"小寒":(6.11,5)
    ]

    private static let jieToMonth: [String: Int] = [
        "立春":2,"惊蛰":3,"清明":4,"立夏":5,"芒种":6,"小暑":7,
        "立秋":8,"白露":9,"寒露":10,"立冬":11,"大雪":12,"小寒":1
    ]

    private static let branchHidden: [String: [(String, Double)]] = [
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
        "亥": [("壬", 0.7), ("甲", 0.3)]
    ]

    private static let seasonalStrength: [String: [String: Double]] = [
        "寅": ["wood": 1.0, "fire": 0.7, "water": 0.4, "metal": 0.2, "earth": 0.3],
        "卯": ["wood": 1.0, "fire": 0.7, "water": 0.4, "metal": 0.2, "earth": 0.3],
        "巳": ["fire": 1.0, "earth": 0.7, "wood": 0.3, "metal": 0.3, "water": 0.2],
        "午": ["fire": 1.0, "earth": 0.7, "wood": 0.3, "metal": 0.3, "water": 0.2],
        "申": ["metal": 1.0, "water": 0.7, "earth": 0.4, "fire": 0.3, "wood": 0.2],
        "酉": ["metal": 1.0, "water": 0.7, "earth": 0.4, "fire": 0.3, "wood": 0.2],
        "亥": ["water": 1.0, "wood": 0.7, "metal": 0.3, "earth": 0.3, "fire": 0.2],
        "子": ["water": 1.0, "wood": 0.7, "metal": 0.3, "earth": 0.3, "fire": 0.2],
        "辰": ["earth": 1.0, "metal": 0.7, "fire": 0.5, "wood": 0.4, "water": 0.3],
        "戌": ["earth": 1.0, "metal": 0.7, "fire": 0.5, "wood": 0.4, "water": 0.3],
        "丑": ["earth": 1.0, "metal": 0.7, "water": 0.5, "wood": 0.3, "fire": 0.3],
        "未": ["earth": 1.0, "fire": 0.7, "wood": 0.5, "metal": 0.3, "water": 0.3]
    ]

    private static let elemCycle: [String: [String: String]] = [
        "wood":  ["gen": "water", "leak": "fire",  "controls": "earth", "beaten_by": "metal"],
        "fire":  ["gen": "wood",  "leak": "earth", "controls": "metal", "beaten_by": "water"],
        "earth": ["gen": "fire",  "leak": "metal", "controls": "water", "beaten_by": "wood"],
        "metal": ["gen": "earth", "leak": "water", "controls": "wood",  "beaten_by": "fire"],
        "water": ["gen": "metal", "leak": "wood",  "controls": "fire",  "beaten_by": "earth"]
    ]

    private let precomputedJieDates: [Int: [String: Date]]

    private let calendarUTC: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }()

    init(precomputedJieDates: [Int: [String: Date]] = [:]) {
        self.precomputedJieDates = precomputedJieDates
    }

    func calculateChart(for info: BirthInfo) throws -> BaziChart {
        let y = info.year
        let m = info.month
        let d = info.day

        let yearData = yearPillar(year: y, month: m, day: d)
        let yearPillar = BaziPillar(
            heavenlyStem: yearData.gan,
            earthlyBranch: yearData.zhi,
            element: BaziService.ganToElement[yearData.gan] ?? ""
        )

        let monthData = monthPillar(year: y, month: m, day: d, yearGan: yearData.gan)
        let monthPillar = BaziPillar(
            heavenlyStem: monthData.gan,
            earthlyBranch: monthData.zhi,
            element: BaziService.ganToElement[monthData.gan] ?? ""
        )

        let dayData = dayPillar(year: y, month: m, day: d)
        let dayPillar = BaziPillar(
            heavenlyStem: dayData.gan,
            earthlyBranch: dayData.zhi,
            element: BaziService.ganToElement[dayData.gan] ?? ""
        )

        var hourPillar = BaziPillar(heavenlyStem: "", earthlyBranch: "", element: "")
        var hourGan: String?
        var hourZhi: String?

        if let hour = info.hour,
           let longitude = info.longitude {
            let minute = info.minute ?? 0
            let tz = info.timeZone ?? TimeZone(secondsFromGMT: Int(round(longitude / 15.0)) * 3600) ?? TimeZone(secondsFromGMT: 0)!
            guard let localDate = makeDate(year: y, month: m, day: d, hour: hour, minute: minute, timeZone: tz) else {
                throw BaziError.invalidDateComponents
            }
            let trueSolar = standardToTrueSolar(localDate: localDate, timeZone: tz, longitude: longitude)
            let hourBranch = solarTimeToZhi(trueSolar: trueSolar, timeZone: tz)
            let dayGanIndex = BaziService.gan.firstIndex(of: dayData.gan) ?? 0
            let branchIndex = BaziService.zhi.firstIndex(of: hourBranch) ?? 0
            let stem = BaziService.gan[(dayGanIndex * 2 + branchIndex) % BaziService.gan.count]
            hourGan = stem
            hourZhi = hourBranch
            hourPillar = BaziPillar(
                heavenlyStem: stem,
                earthlyBranch: hourBranch,
                element: BaziService.ganToElement[stem] ?? ""
            )
        }

        let elements = calculateElementsDistribution(yearGan: yearData.gan,
                                                     yearZhi: yearData.zhi,
                                                     monthGan: monthData.gan,
                                                     monthZhi: monthData.zhi,
                                                     dayGan: dayData.gan,
                                                     dayZhi: dayData.zhi,
                                                     hourGan: hourGan,
                                                     hourZhi: hourZhi,
                                                     seasonBranch: monthData.zhi)

        return BaziChart(
            yearPillar: yearPillar,
            monthPillar: monthPillar,
            dayPillar: dayPillar,
            hourPillar: hourPillar,
            dayMaster: dayData.gan,
            elements: elements
        )
    }

    func analyzeLuckyElements(chart: BaziChart) -> (lucky: [String], unlucky: [String]) {
        let dmElement = BaziService.ganToElement[chart.dayMaster] ?? ""
        guard let cycle = BaziService.elemCycle[dmElement] else {
            return ([], [])
        }

        let strength = evaluateDayMasterStrength(
            dayGan: chart.dayMaster,
            yearGan: chart.yearPillar.heavenlyStem,
            yearZhi: chart.yearPillar.earthlyBranch,
            monthGan: chart.monthPillar.heavenlyStem,
            monthZhi: chart.monthPillar.earthlyBranch,
            dayZhi: chart.dayPillar.earthlyBranch,
            hourGan: chart.hourPillar.heavenlyStem.isEmpty ? nil : chart.hourPillar.heavenlyStem,
            hourZhi: chart.hourPillar.earthlyBranch.isEmpty ? nil : chart.hourPillar.earthlyBranch
        )

        var lucky: [String] = []
        var unlucky: [String] = []

        if strength.label == "身强" {
            lucky.append(cycle["controls"] ?? "")
            lucky.append(cycle["leak"] ?? "")
            unlucky.append(dmElement)
            unlucky.append(cycle["gen"] ?? "")
        } else {
            lucky.append(dmElement)
            lucky.append(cycle["gen"] ?? "")
            unlucky.append(cycle["leak"] ?? "")
            unlucky.append(cycle["beaten_by"] ?? "")
        }

        let luckyDedup = deduplicateKeepingOrder(lucky)
        let unluckyDedup = deduplicateKeepingOrder(unlucky)
        return (luckyDedup, unluckyDedup)
    }

    func getLuckyDirections(from elements: [String]) -> [String] {
        let elementToDirections: [String: [String]] = [
            "wood": ["east", "southeast"],
            "fire": ["south"],
            "earth": ["center", "northeast", "southwest"],
            "metal": ["west", "northwest"],
            "water": ["north"]
        ]
        var set: Set<String> = []
        for e in elements {
            if let dirs = elementToDirections[e] {
                set.formUnion(dirs)
            }
        }
        return Array(set)
    }

    func getLuckyColors(from elements: [String]) -> [String] {
        let elementToColors: [String: [String]] = [
            "wood": ["green", "cyan", "turquoise"],
            "fire": ["red", "orange", "purple"],
            "earth": ["yellow", "brown", "beige"],
            "metal": ["white", "silver", "gold"],
            "water": ["black", "blue", "gray"]
        ]
        var result: [String] = []
        for e in elements {
            if let colors = elementToColors[e] {
                result.append(contentsOf: colors)
            }
        }
        return result
    }

    // MARK: - Private Helpers

    private func deduplicateKeepingOrder(_ list: [String]) -> [String] {
        var seen: Set<String> = []
        var result: [String] = []
        for item in list where !item.isEmpty {
            if !seen.contains(item) {
                seen.insert(item)
                result.append(item)
            }
        }
        return result
    }

    private func makeDate(year: Int,
                          month: Int,
                          day: Int,
                          hour: Int,
                          minute: Int,
                          timeZone: TimeZone) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        return calendar.date(from: comps)
    }

    private func standardToTrueSolar(localDate: Date,
                                     timeZone: TimeZone,
                                     longitude: Double) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let tzOffsetHours = Double(timeZone.secondsFromGMT(for: localDate)) / 3600.0
        let lstm = 15.0 * tzOffsetHours
        let longitudeCorrection = 4.0 * (longitude - lstm)

        let dayOfYear = Double(calendar.ordinality(of: .day, in: .year, for: localDate) ?? 1)
        let B = 2.0 * Double.pi * (dayOfYear - 81.0) / 364.0
        let eot = 229.18 * (0.000075 + 0.001868 * cos(B) - 0.032077 * sin(B)
                            - 0.014615 * cos(2*B) - 0.040849 * sin(2*B))
        let deltaMinutes = longitudeCorrection + eot
        return localDate.addingTimeInterval(deltaMinutes * 60.0)
    }

    private func solarTimeToZhi(trueSolar: Date, timeZone: TimeZone) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.hour, .minute], from: trueSolar)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let total = hour * 60 + minute

        switch total {
        case let t where t >= 23*60 || t < 1*60: return "子"
        case 1*60..<3*60: return "丑"
        case 3*60..<5*60: return "寅"
        case 5*60..<7*60: return "卯"
        case 7*60..<9*60: return "辰"
        case 9*60..<11*60: return "巳"
        case 11*60..<13*60: return "午"
        case 13*60..<15*60: return "未"
        case 15*60..<17*60: return "申"
        case 17*60..<19*60: return "酉"
        case 19*60..<21*60: return "戌"
        default: return "亥"
        }
    }

    private func calculateElementsDistribution(yearGan: String,
                                               yearZhi: String,
                                               monthGan: String,
                                               monthZhi: String,
                                               dayGan: String,
                                               dayZhi: String,
                                               hourGan: String?,
                                               hourZhi: String?,
                                               seasonBranch: String) -> BaziElements {
        var elemScore: [String: Double] = ["wood": 0, "fire": 0, "earth": 0, "metal": 0, "water": 0]

        let weightStem = 1.0
        let weightYearBranch = 1.0
        let weightMonthBranch = 1.5
        let weightDayBranch = 1.2
        let weightHourBranch = 1.0

        func addStem(_ gan: String?, weight: Double) {
            guard let gan = gan,
                  let element = BaziService.ganToElement[gan] else { return }
            elemScore[element, default: 0] += weight
        }

        func addBranch(_ zhi: String?, positionWeight: Double) {
            guard let zhi = zhi else { return }
            if let hidden = BaziService.branchHidden[zhi] {
                let season = BaziService.seasonalStrength[seasonBranch] ?? [:]
                for (gan, w) in hidden {
                    guard let element = BaziService.ganToElement[gan] else { continue }
                    let boost = season[element] ?? 0.4
                    elemScore[element, default: 0] += positionWeight * w * (0.8 + 0.4 * boost)
                }
            } else if let element = BaziService.zhiToElement[zhi] {
                elemScore[element, default: 0] += positionWeight
            }
        }

        addStem(yearGan, weight: weightStem)
        addStem(monthGan, weight: weightStem)
        addStem(dayGan, weight: weightStem)
        addStem(hourGan, weight: weightStem)

        addBranch(yearZhi, positionWeight: weightYearBranch)
        addBranch(monthZhi, positionWeight: weightMonthBranch)
        addBranch(dayZhi, positionWeight: weightDayBranch)
        addBranch(hourZhi, positionWeight: weightHourBranch)

        let total = elemScore.values.reduce(0, +)
        let safeTotal = total == 0 ? 1.0 : total

        func round2(_ value: Double) -> Double {
            (value * 100).rounded() / 100.0
        }

        return BaziElements(
            wood: round2(elemScore["wood", default: 0] / safeTotal * 100),
            fire: round2(elemScore["fire", default: 0] / safeTotal * 100),
            earth: round2(elemScore["earth", default: 0] / safeTotal * 100),
            metal: round2(elemScore["metal", default: 0] / safeTotal * 100),
            water: round2(elemScore["water", default: 0] / safeTotal * 100)
        )
    }

    private func evaluateDayMasterStrength(dayGan: String,
                                           yearGan: String,
                                           yearZhi: String,
                                           monthGan: String,
                                           monthZhi: String,
                                           dayZhi: String,
                                           hourGan: String?,
                                           hourZhi: String?) -> (label: String, score: Double) {
        let dmElement = BaziService.ganToElement[dayGan] ?? ""
        guard let cycle = BaziService.elemCycle[dmElement] else {
            return ("身弱", 0)
        }

        let season = BaziService.seasonalStrength[monthZhi] ?? [:]
        let seasonScore = (season[dmElement] ?? 0.4) * 3.0

        func hiddenScore(_ zhi: String, weight: Double) -> Double {
            guard let hidden = BaziService.branchHidden[zhi] else { return 0.0 }
            var score = 0.0
            for (gan, w) in hidden {
                guard let element = BaziService.ganToElement[gan] else { continue }
                if element == dmElement {
                    score += 1.0 * w * weight
                } else if element == cycle["gen"] {
                    score += 0.8 * w * weight
                }
            }
            return score
        }

        var rootScore = 0.0
        rootScore += hiddenScore(dayZhi, weight: 2.0)
        rootScore += hiddenScore(monthZhi, weight: 1.5)
        rootScore += hiddenScore(yearZhi, weight: 1.0)
        if let hz = hourZhi {
            rootScore += hiddenScore(hz, weight: 1.0)
        }

        func stemEffect(_ gan: String?, _ weight: Double) -> Double {
            guard let gan = gan,
                  let element = BaziService.ganToElement[gan] else { return 0.0 }
            if element == dmElement {
                return 1.0 * weight
            }
            if element == cycle["gen"] {
                return 0.8 * weight
            }
            if element == cycle["leak"] {
                return -0.7 * weight
            }
            if element == cycle["controls"] {
                return -0.9 * weight
            }
            if element == cycle["beaten_by"] {
                return -1.1 * weight
            }
            return 0.0
        }

        var helpPenalty = 0.0
        helpPenalty += stemEffect(monthGan, 1.5)
        helpPenalty += stemEffect(dayGan, 1.2)
        helpPenalty += stemEffect(yearGan, 1.0)
        helpPenalty += stemEffect(hourGan, 1.0)

        let raw = seasonScore + rootScore + helpPenalty
        let score = max(0.0, min(100.0, 50.0 + raw * 6.0))
        let label = score >= 55.0 ? "身强" : "身弱"
        return (label, score.rounded(toPlaces: 1))
    }

    private func yearPillar(year: Int, month: Int, day: Int) -> (pillar: String, gan: String, zhi: String) {
        let lichun = yearJieDates(year: year)["立春"]!
        let current = calendarUTC.date(from: DateComponents(year: year, month: month, day: day))!
        let adjustedYear = current < lichun ? year - 1 : year
        let offset = (adjustedYear - 1984) % 60
        let idx60 = (offset + 60) % 60
        let gan = BaziService.gan[idx60 % 10]
        let zhi = BaziService.zhi[idx60 % 12]
        return (gan + zhi, gan, zhi)
    }

    private func monthPillar(year: Int, month: Int, day: Int, yearGan: String) -> (pillar: String, gan: String, zhi: String, index: Int) {
        let current = calendarUTC.date(from: DateComponents(year: year, month: month, day: day))!
        let thisYearDates = yearJieDates(year: year)
        let referenceYear = current >= thisYearDates["立春"]! ? year : year - 1
        let jy = yearJieDates(year: referenceYear)
        let jn = yearJieDates(year: referenceYear + 1)

        let boundaries = [
            jy["立春"]!, jy["惊蛰"]!, jy["清明"]!, jy["立夏"]!,
            jy["芒种"]!, jy["小暑"]!, jy["立秋"]!, jy["白露"]!,
            jy["寒露"]!, jy["立冬"]!, jy["大雪"]!, jn["小寒"]!,
            jn["立春"]!
        ]

        var monthIndex = 11
        for i in 0..<12 {
            if boundaries[i] <= current && current < boundaries[i+1] {
                monthIndex = i
                break
            }
        }

        let zhi = BaziService.zhi[(2 + monthIndex) % 12]
        let baseGan = BaziService.yearGanToM1Gan[yearGan] ?? "丙"
        let ganIndex = (BaziService.gan.firstIndex(of: baseGan) ?? 0 + monthIndex) % 10
        let gan = BaziService.gan[ganIndex]
        return (gan + zhi, gan, zhi, monthIndex + 1)
    }

    private func dayPillar(year: Int, month: Int, day: Int) -> (pillar: String, gan: String, zhi: String) {
        let anchor = gregorianToJDN(year: 1984, month: 2, day: 2)
        let jdn = gregorianToJDN(year: year, month: month, day: day)
        let offset = (jdn - anchor + 2) % 60
        let idx60 = (offset + 60) % 60
        let gan = BaziService.gan[idx60 % 10]
        let zhi = BaziService.zhi[idx60 % 12]
        return (gan + zhi, gan, zhi)
    }

    private func gregorianToJDN(year: Int, month: Int, day: Int) -> Int {
        let a = (14 - month) / 12
        let y = year + 4800 - a
        let m = month + 12 * a - 3
        return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
    }

    private func approxJieqiDay(year: Int, name: String) -> Int {
        if let coeffs = BaziService.jieCoeffs[name] {
            let (C, fix) = coeffs
            let y = Double(year - 1900)
            return Int((C + 0.2422 * y) - floor(y / 4.0)) + fix
        }
        return 1
    }

    private func yearJieDates(year: Int) -> [String: Date] {
        if let precomputed = precomputedJieDates[year] {
            return precomputed
        }
        var result: [String: Date] = [:]
        for (name, _) in BaziService.jieCoeffs {
            let month = BaziService.jieToMonth[name] ?? 1
            let day = approxJieqiDay(year: year, name: name)
            if let date = calendarUTC.date(from: DateComponents(year: year, month: month, day: day)) {
                result[name] = date
            }
        }
        return result
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
