import SwiftUI
import Algorithms

struct FoldSurface: Identifiable, ViewModifier {
    var id: Int
    var angle: Angle
    var edge: Edge
    var focalLength: CGFloat
    var scale: CGFloat
    
    var rotationAxis: (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch edge {
        case .top: (x: 1, y: 0, z: 0)
        case .bottom: (x: -1, y: 0, z: 0)
        case .leading: (x: 0, y: -1, z: 0)
        case .trailing: (x: 0, y: 1, z: 0)
        }
    }
    
    var rotation: Rotation3DEffect {
        .init(angle: angle, axis: rotationAxis, anchor: edge.opposite.middle, focalLength: focalLength)
    }
    
    func body(content: Content) -> some View {
        let scaleSize = switch edge.axis {
        case .horizontal: CGSize(width: 1, height: scale)
        case .vertical: CGSize(width: scale, height: 1)
        }
        content
            .modifier(rotation)
            .layoutBounds { proposal, view in
                rotation.measurements.bounds(for: view.sizeThatFits(proposal))
            }
            .scaleEffect(scaleSize)
    }
}

extension FoldSurface {
    func scale(for direction: Direction) -> CGFloat {
        if direction == edge.direction {
            scale * rotation.measurements.length(of: edge.segment)
        } else {
            scale
        }
    }
    func id(for direction: Direction) -> Int {
        switch direction {
        case .forward: id + 1
        case .backward: id - 1
        }
    }
    
    // FIXME: Maybe just take adjustment as argument, and have caller set the indices?
    // FIXME: LOTS of surfaces if angle is near 0 (and infinte at 0!!)
    // TODO: Support range limit, maybe via new FoldStyle?
    static func fold<Style: FoldStyle>(_ style: Style, axis: Axis, focalLength: CGFloat, progress: FoldProgress, cull: (Angle) -> Bool = { abs($0.degrees) >= 90 }) -> [FoldSurface] {
        let curve = UnitCurve.circularEaseInOut
        let adjustment = progress.adjustment.curved(curve)
        let angle = adjustment.angle(backward: style.forward.first(where: { _ in true })!, center: .zero, forward: style.forward.first(where: { _ in true })!)
        let middle = FoldSurface(id: progress.index, angle: angle, edge: .init(axis: axis, direction: progress.adjustment.anchor > 0.5 ? .forward : .backward), focalLength: focalLength, scale: 1)
        let forward = chain([Angle.zero], style.forward).adjacentTriples().lazy.reductions(middle) { surface, angles in
            FoldSurface(
                id: surface.id(for: .forward),
                angle: adjustment.angle(backward: angles.2, center: angles.1, forward: angles.0),
                edge: .init(axis: axis, direction: .forward),
                focalLength: surface.focalLength,
                scale: surface.scale(for: .forward)
            )
        }.dropFirst().prefix(while: { !cull($0.angle) })
        let backward = chain([Angle.zero], style.backward).adjacentTriples().lazy.reductions(middle) { surface, angles in
            FoldSurface(
                id: surface.id(for: .backward),
                angle: adjustment.angle(backward: angles.0, center: angles.1, forward: angles.2),
                edge: .init(axis: axis, direction: .backward),
                focalLength: surface.focalLength,
                scale: surface.scale(for: .backward)
            )
        }.dropFirst().prefix(while: { !cull($0.angle) })
        return backward.reversed() + [middle] + forward
    }
}
