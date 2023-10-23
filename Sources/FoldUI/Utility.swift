import SwiftUI

enum Direction: Equatable {
    case forward
    case backward
}
extension Edge {
    init(axis: Axis, direction: Direction) {
        switch (axis, direction) {
        case (.horizontal, .backward): self = .leading
        case (.horizontal, .forward): self = .trailing
        case (.vertical, .backward): self = .top
        case (.vertical, .forward): self = .bottom
        }
    }
    
    var opposite: Self {
        switch self {
        case .top: .bottom
        case .bottom: .top
        case .leading: .trailing
        case .trailing: .leading
        }
    }
    
    var middle: UnitPoint {
        switch self {
        case .top: .top
        case .bottom: .bottom
        case .leading: .leading
        case .trailing: .trailing
        }
    }

    var segment: (UnitPoint, UnitPoint) {
        switch self {
        case .top: (.topLeading, .topTrailing)
        case .bottom: (.bottomLeading, .bottomTrailing)
        case .leading: (.topLeading, .bottomLeading)
        case .trailing: (.topTrailing, .bottomTrailing)
        }
    }

    var axis: Axis {
        switch self {
        case .top, .bottom: .vertical
        case .leading, .trailing: .horizontal
        }
    }
    
    var direction: Direction {
        switch self {
        case .top, .leading: .backward
        case .bottom, .trailing: .forward
        }
    }
}

extension Angle {
    @inlinable static func +(lhs: Angle, rhs: Angle) -> Angle {
        return Angle(radians: lhs.radians + rhs.radians)
    }
    
    @inlinable static func -(lhs: Angle, rhs: Angle) -> Angle {
        return Angle(radians: lhs.radians - rhs.radians)
    }
    
    @inlinable static func *(lhs: Angle, rhs: Double) -> Angle {
        return Angle(radians: lhs.radians * rhs)
    }

    @inlinable static func *(lhs: Double, rhs: Angle) -> Angle {
        return Angle(radians: lhs * rhs.radians)
    }
    
    @inlinable static func /(lhs: Angle, rhs: Double) -> Angle {
        return Angle(radians: lhs.radians / rhs)
    }
    
    func interpolated(towards other: Self, amount: Double) -> Self {
        (1 - amount) * self + amount * other
    }
}
extension Range<Angle> {
    func interpolated(amount: Double) -> Angle {
        lowerBound.interpolated(towards: upperBound, amount: amount)
    }
}

extension Sequence {
    func adjacentTriples() -> some Sequence<(Element, Element, Element)> {
        adjacentPairs().adjacentPairs().lazy.map { ($0.0.0, $0.0.1, $0.1.1) }
    }
}
