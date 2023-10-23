import SwiftUI

struct BoundsLayout: Layout {
    var bounds: (ProposedViewSize, LayoutSubview) -> CGRect
    
    func makeCache(subviews: Subviews) -> CGRect {
        .zero
    }
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CGRect
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        precondition(subviews.count == 1)
        cache = bounds(proposal, subviews[0])
        return cache.size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CGRect
    ) {
        guard !subviews.isEmpty else { return }
        precondition(subviews.count == 1)
        subviews[0].place(at: .init(x: bounds.origin.x - cache.origin.x, y: bounds.origin.y - cache.origin.y), anchor: .topLeading, proposal: proposal)
    }
    
    func spacing(
        subviews: Self.Subviews,
        cache: inout Self.Cache
    ) -> ViewSpacing {
        .zero
    }
}

extension View {
    func layoutBounds(_ bounds: @escaping (ProposedViewSize, LayoutSubview) -> CGRect) -> some View {
        BoundsLayout(bounds: bounds) {
            self
        }
    }
}
