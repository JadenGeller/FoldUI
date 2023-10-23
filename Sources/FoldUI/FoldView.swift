import SwiftUI

public struct FoldView<Content: View, Style: FoldStyle>: View, Animatable {
    var style: Style
    var axis: Axis
    var progress: FoldProgress

    // TODO: It might be nice if this could be animated, but it seems to break things with NaN and infinity
    var focalLength: CGFloat
    
    // FIXME: Allow limiting to index / geometric range
    var content: (Int) -> Content
    
    public init(style: Style, axis: Axis, progress: FoldProgress, focalLength: CGFloat = 1, @ViewBuilder content: @escaping (Int) -> Content) {
        self.style = style
        self.axis = axis
        self.progress = progress
        self.focalLength = focalLength
        self.content = content
    }

    public var animatableData: AnimatablePair<Double, Style.AnimatableData> {
        get {
            .init(progress.offset, style.animatableData)
        }
        set {
            (progress, style.animatableData) = (.init(offset: newValue.first), newValue.second)
        }
    }
    
    var layout: some Layout {
        switch axis {
        case .horizontal: AnyLayout(HStackLayout(spacing: 0))
        case .vertical: AnyLayout(VStackLayout(spacing: 0))
        }
    }
    
    @Environment(\.layoutDirection) var layoutDirection
    public var body: some View {
        layout {
            ForEach(FoldSurface.fold(style, axis: axis, focalLength: focalLength, progress: progress)) { surface in
                content(surface.id)
                    .modifier(surface)
            }
            .geometryGroup()
        }
    }
}
