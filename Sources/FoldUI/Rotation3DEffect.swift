import SwiftUI
import simd

struct Rotation3DEffect: GeometryEffect {
    var angle: Angle
    var axis: (x: CGFloat, y: CGFloat, z: CGFloat)
    var anchor: UnitPoint = .center
    var anchorZ: CGFloat = 0
    var focalLength: CGFloat
        
    var unitTransform3D: CATransform3D {
        var rotate = CATransform3DIdentity
        rotate.m34 = -1 / focalLength
        rotate = CATransform3DRotate(rotate, CGFloat(angle.radians), axis.x, axis.y, axis.z)
        
        let translateToAnchor = CATransform3DMakeTranslation(-anchor.x, -anchor.y, -anchorZ)
        let translateFromAnchor = CATransform3DMakeTranslation(anchor.x, anchor.y, anchorZ)

        return CATransform3DConcat(translateToAnchor, CATransform3DConcat(rotate, translateFromAnchor))
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        .init(CATransform3DConcat(
            CATransform3DMakeScale(1 / size.width, 1 / size.height, 1),
            CATransform3DConcat(unitTransform3D, CATransform3DMakeScale(size.width, size.height, 1))
        ))
    }
    
    struct MeasurementProxy {
        var transform: simd_double4x4

        func transform(_ anchor: UnitPoint) -> UnitPoint {
            let result = transform * SIMD4(anchor.x, anchor.y, 0, 1)
            return .init(x: result.x / result.w, y: result.y / result.w)
        }
        
        func length(of segment: (UnitPoint, UnitPoint)) -> CGFloat {
            let segment = (transform(segment.0), transform(segment.1))
            return sqrt(pow(segment.1.x - segment.0.x, 2) + pow(segment.1.y - segment.0.y, 2))
        }
        
        func bounds(for size: CGSize) -> CGRect {
            var minPoint = CGPoint(x: Double.infinity, y: Double.infinity)
            var maxPoint = CGPoint(x: -Double.infinity, y: -Double.infinity)
            for anchor in [.topLeading, .topTrailing, .bottomLeading, .bottomTrailing] as [UnitPoint] {
                let point = transform(anchor)
                minPoint.x = min(minPoint.x, point.x)
                minPoint.y = min(minPoint.y, point.y)
                maxPoint.x = max(maxPoint.x, point.x)
                maxPoint.y = max(maxPoint.y, point.y)
            }
            
            return .init(
                x: minPoint.x * size.width,
                y: minPoint.y * size.height,
                width: (maxPoint.x - minPoint.x) * size.width,
                height: (maxPoint.y - minPoint.y) * size.height
            )
        }
    }
    
    var measurements: MeasurementProxy {
        return .init(transform: unitTransform3D.matrix)
    }
}

extension CATransform3D {
    var matrix: simd_double4x4 {
        simd_double4x4([
            SIMD4<Double>(m11, m12, m13, m14),
            SIMD4<Double>(m21, m22, m23, m24),
            SIMD4<Double>(m31, m32, m33, m34),
            SIMD4<Double>(m41, m42, m43, m44)
        ])
    }
}
