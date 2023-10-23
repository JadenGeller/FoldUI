import SwiftUI

public struct FoldProgress {
    public var offset: Double
    public init(offset: Double) {
        self.offset = offset
    }
    
    public var index: Int {
        get {
            Int(offset + 0.5)
        }
        set {
            offset = Double(newValue) - 0.5
        }
    }
    
    // FIXME: Would it be simpler if this stored (minor) offset?
    public struct Adjustment {
        public var anchor: Double
        public init(anchor: Double) {
            self.anchor = anchor
        }
        
        // FIXME: This is the opposite the name we want!!
        // FIXME: Our terminology is inconsistent
        var heading: Direction {
            if anchor > 0.5 {
                .forward
            } else {
                .backward
            }
        }
        
        var distance: Double {
            get {
                switch heading {
                case .backward: 0.5 - anchor
                case .forward: anchor - 0.5
                }
            }
            set {
                self = .init(distance: newValue, heading: heading)
            }
        }
        init(distance: Double, heading: Direction) {
            switch heading {
            case .backward: anchor = 0.5 - distance
            case .forward: anchor = 0.5 + distance
            }
        }
        
        // TODO: Should this be a subscript or something so we can get/set?
        // TODO: Should there be a way to curve differently based on which direction you're moving in from last stationary?
        public func curved(_ curve: UnitCurve) -> Self {
            switch heading {
            case .forward: .init(distance: curve.value(at: distance), heading: .forward)
            case .backward: .init(distance: 1 - curve.value(at: 1 - distance), heading: .backward)
            }
        }
        
        func angle(backward: Angle, center: Angle, forward: Angle) -> Angle {
            switch heading {
            case .forward: return center.interpolated(towards: backward, amount: distance)
            case .backward: return center.interpolated(towards: forward, amount: distance)
            }
        }
    }
    public var adjustment: Adjustment {
        get {
            .init(anchor: 0.5 + (CGFloat(index) - offset))
        }
        set {
            offset = CGFloat(index) - newValue.anchor + 0.5
        }
    }
}

extension FoldProgress.Adjustment {
    public static var center: Self {
        .init(anchor: 0.5)
    }
}
