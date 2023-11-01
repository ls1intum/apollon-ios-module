import Foundation
import SwiftUI
import ApollonShared

open class ApollonViewModel: ObservableObject {
    @Published public var umlModel: UMLModel?
    @Published public var diagramType: UMLDiagramType?
    @Published public var fontSize: CGFloat
    @Published public var diagramOffset: CGPoint
    @Published public var isGridBackground: Bool
    public var diagramTypeUnsupported = false
    
    public init(umlModel: UMLModel? = nil, diagramType: UMLDiagramType? = nil, fontSize: CGFloat? = nil, diagramOffset: CGPoint? = nil, isGridBackground: Bool? = nil) {
        self.umlModel = umlModel
        self.diagramType = diagramType ?? umlModel?.type
        self.fontSize = fontSize ?? 14.0
        self.diagramOffset = diagramOffset ?? CGPoint(x: 0, y: 0)
        self.isGridBackground = isGridBackground ?? false
    }
    
    @MainActor
    public func setup(umlModel: UMLModel, diagramType: UMLDiagramType?, fontSize: CGFloat?, diagramOffset: CGPoint?, isGridBackground: Bool?) {
        self.umlModel = umlModel
        self.diagramType = diagramType ?? umlModel.type
        self.fontSize = fontSize ?? 14.0
        self.diagramOffset = diagramOffset ?? CGPoint(x: 0, y: 0)
        self.isGridBackground = isGridBackground ?? false
        determineChildren()
    }
    
    @MainActor
    public func render(_ context: inout GraphicsContext, size: CGSize) {
        guard let model = self.umlModel,
              let modelType = self.diagramType,
              !diagramTypeUnsupported else {
            return
        }
        let umlContext = UMLGraphicsContext(context, offset: diagramOffset)
        let canvasBounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let renderer = UMLDiagramRendererFactory.renderer(for: modelType,
                                                          context: umlContext,
                                                          canvasBounds: canvasBounds,
                                                          fontSize: fontSize)
        if let renderer {
            renderer.render(umlModel: model)
        } else {
            log.error("Attempted to draw an unknown diagram type")
            diagramTypeUnsupported = true
        }
    }
    
    public func determineChildren() {
        guard let elements = umlModel?.elements else {
            log.warning("Could not find elements in the model")
            return
        }
        
        var potentialChildren = elements.values.filter({ $0.owner != nil })
        
        for element in elements.reversed() {
            for (index, potentialChild) in potentialChildren.enumerated().reversed() where potentialChild.owner == element.key {
                elements[element.key]?.addChild(potentialChild)
                potentialChildren.remove(at: index)
            }
        }
        umlModel?.elements = elements
    }
}
