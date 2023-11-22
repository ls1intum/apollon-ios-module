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
    public var diagramTypeUnsupported = false

    public init(umlModel: UMLModel, diagramType: UMLDiagramType, fontSize: CGFloat, diagramOffset: CGPoint, isGridBackground: Bool) {
        self.umlModel = umlModel
        self.diagramType = diagramType
        self.fontSize = fontSize
        self.diagramOffset = diagramOffset
        self.isGridBackground = isGridBackground
        self.determineChildren()
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
