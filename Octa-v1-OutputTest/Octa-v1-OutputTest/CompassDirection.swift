import Foundation

enum CompassDirection: String, CaseIterable, Identifiable {
    case north = "北"
    case northeast = "东北"
    case east = "东"
    case southeast = "东南"
    case south = "南"
    case southwest = "西南"
    case west = "西"
    case northwest = "西北"

    var id: String { rawValue }

    /// 文案（与 prompt 传参保持一致）
    var promptValue: String { rawValue }

    /// 对应角度（0° 指向正北，顺时针递增）
    var angle: Double {
        switch self {
        case .north: return 0
        case .northeast: return 45
        case .east: return 90
        case .southeast: return 135
        case .south: return 180
        case .southwest: return 225
        case .west: return 270
        case .northwest: return 315
        }
    }

    /// 根据角度（0~360，0 为正北）映射方向
    static func direction(from angle: Double) -> CompassDirection {
        let normalized = (angle.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        let index = Int((normalized + 22.5) / 45.0) % CompassDirection.allCases.count
        return CompassDirection.allCases[index]
    }
}
