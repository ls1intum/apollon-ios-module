import SwiftUI

/// A wrapper for `GraphicsContext` to customize some of its behavior
public struct UMLGraphicsContext {
    public var baseGraphicsContext: GraphicsContext
    public var xOffset: CGFloat
    public var yOffset: CGFloat
    
    public init(_ context: GraphicsContext, offset: CGPoint) {
        self.baseGraphicsContext = context
        self.xOffset = offset.x
        self.yOffset = offset.y
    }
    
    // MARK: - Fill
    public func fill(_ path: Path, with shading: GraphicsContext.Shading, style: FillStyle = FillStyle()) {
        let pathWithOffset = path.offsetBy(dx: xOffset, dy: yOffset)
        baseGraphicsContext.fill(pathWithOffset, with: shading, style: style)
    }
    
    // MARK: - Stroke
    public func stroke(_ path: Path, with shading: GraphicsContext.Shading, lineWidth: CGFloat = 1) {
        let pathWithOffset = path.offsetBy(dx: xOffset, dy: yOffset)
        baseGraphicsContext.stroke(pathWithOffset, with: shading, lineWidth: lineWidth)
    }
    
    public func stroke(_ path: Path, with shading: GraphicsContext.Shading, style: StrokeStyle) {
        let pathWithOffset = path.offsetBy(dx: xOffset, dy: yOffset)
        baseGraphicsContext.stroke(pathWithOffset, with: shading, style: style)
    }
    
    // MARK: - Draw
    public func draw(_ text: GraphicsContext.ResolvedText, in rect: CGRect) {
        let rectWithOffset = rect.offsetBy(dx: xOffset, dy: yOffset)
        baseGraphicsContext.draw(text, in: rectWithOffset)
    }
    
    public func draw(_ symbol: GraphicsContext.ResolvedSymbol, in rect: CGRect) {
        let rectWithOffset = rect.offsetBy(dx: xOffset, dy: yOffset)
        baseGraphicsContext.draw(symbol, in: rectWithOffset)
    }
    
    public func draw(_ image: GraphicsContext.ResolvedImage, in rect: CGRect, style: FillStyle = FillStyle()) {
        let rectWithOffset = rect.offsetBy(dx: xOffset, dy: yOffset)
        baseGraphicsContext.draw(image, in: rectWithOffset, style: style)
    }
    
    public func draw(_ image: GraphicsContext.ResolvedImage, at point: CGPoint, anchor: UnitPoint = .center) {
        let pointWithOffset = CGPoint(x: point.x + xOffset, y: point.y + yOffset)
        baseGraphicsContext.draw(image, at: pointWithOffset, anchor: anchor)
    }
    
    // MARK: - Resolve
    public func resolve(_ text: Text) -> GraphicsContext.ResolvedText {
        baseGraphicsContext.resolve(text)
    }
    
    public func resolveSymbol<ID>(id: ID) -> GraphicsContext.ResolvedSymbol? where ID: Hashable {
        baseGraphicsContext.resolveSymbol(id: id)
    }
}
