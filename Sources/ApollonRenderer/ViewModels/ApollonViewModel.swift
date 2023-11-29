import Foundation
import SwiftUI
import ApollonShared

@MainActor
open class ApollonViewModel: ObservableObject {
    @Published public var umlModel: UMLModel
    @Published public var diagramType: UMLDiagramType
    @Published public var fontSize: CGFloat
    @Published public var diagramOffset: CGPoint
    @Published public var isGridBackground: Bool
    
    @Published public var geometrySize = CGSize.zero
    @Published public var initialDiagramSize = CGSize.zero
    
    @Published public var startDragLocation = CGPoint.zero
    @Published public var currentDragLocation = CGPoint.zero
    @Published public var dragStarted = true
    
    @Published public var scale: CGFloat = 1.0
    @Published public var progressingScale: CGFloat = 1.0
    @Published public var idealScale: CGFloat = 1.0
    public var minScale: CGFloat = 0.2
    public var maxScale: CGFloat = 3.0
    
    public var diagramTypeUnsupported = false
    
    public init(umlModel: UMLModel, diagramType: UMLDiagramType, fontSize: CGFloat, diagramOffset: CGPoint, isGridBackground: Bool) {
        self.umlModel = umlModel
        self.diagramType = diagramType
        self.fontSize = fontSize
        self.diagramOffset = diagramOffset
        self.isGridBackground = isGridBackground
        self.determineChildren()
    }
    
    public func setDragLocation(at point: CGPoint? = nil) {
        if let point {
            currentDragLocation = point
        } else {
            currentDragLocation = CGPoint(x: geometrySize.width / 2, y: geometrySize.height / 2)
        }
    }
    
    public func setupScale(geometrySize: CGSize) {
        self.geometrySize = geometrySize
        self.initialDiagramSize = umlModel.size?.asCGSize ?? CGSize()
        calculateIdealScale()
        scale = idealScale
    }
    
    public func calculateIdealScale() {
        if let size = umlModel.size {
            let scaleWidth = self.geometrySize.width / max(initialDiagramSize.width, size.width)
            let scaleHeight = self.geometrySize.height / max(initialDiagramSize.height, size.height)
            let initialScale = min(scaleWidth, scaleHeight)
            idealScale = min(max(initialScale, minScale), maxScale) - 0.05
        }
    }
    
    public func handleDiagramDrag(_ gesture: DragGesture.Value) {
        if dragStarted {
            dragStarted = false
            startDragLocation = currentDragLocation
        }
        setDragLocation(at: CGPoint(x: startDragLocation.x + gesture.translation.width,
                                    y: startDragLocation.y + gesture.translation.height))
    }
    
    public func handleDiagramMagnification(_ newScale: MagnificationGesture.Value) {
        progressingScale = newScale
        // Enforce zoom out limit
        if progressingScale * scale < minScale {
            progressingScale = minScale / scale
        }
        // Enforce zoom in limit
        if progressingScale * scale > maxScale {
            progressingScale = maxScale / scale
        }
    }
    
    public func handleDiagramMagnificationEnd(_ finalScale: MagnificationGesture.Value) {
        scale *= finalScale
        progressingScale = 1
        // Enforce zoom out limit
        if scale < minScale {
            scale = minScale
        }
        // Enforce zoom in limit
        if scale > maxScale {
            scale = maxScale
        }
    }
    
    public func render(_ context: inout GraphicsContext, size: CGSize) {
        guard !diagramTypeUnsupported else {
            return
        }
        let umlContext = UMLGraphicsContext(context, offset: diagramOffset)
        let canvasBounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let renderer = UMLDiagramRendererFactory.renderer(for: diagramType,
                                                          context: umlContext,
                                                          canvasBounds: canvasBounds,
                                                          fontSize: fontSize)
        if let renderer {
            renderer.render(umlModel: umlModel)
        } else {
            log.error("Attempted to draw an unknown diagram type")
            diagramTypeUnsupported = true
        }
    }
    
    public func determineChildren() {
        guard let elements = umlModel.elements else {
            log.warning("Could not find elements in the model")
            return
        }
        
        var potentialChildren = elements.values.filter({ $0.owner != nil })
        
        for element in elements.reversed() {
            for (index, potentialChild) in potentialChildren.enumerated().reversed() where potentialChild.owner == element.value.id {
                elements[element.key]?.addChild(potentialChild)
                potentialChildren.remove(at: index)
            }
        }
        umlModel.elements = elements
    }
}
