import Foundation
import SwiftUI
import ApollonModels

class DiagramViewModel: ObservableObject {
    @Published var readOnly: Bool = true
    @Published var fontSize: CGFloat = 14.0
    @Published var umlModel: UMLModel?
    //@Published var selectedElement: SelectableUMLItem?
    private var diagramTypeUnsupported = false
    
    @MainActor
    func setup(readOnly: Bool, fontSize: CGFloat, umlModel: UMLModel) {
        self.readOnly = readOnly
        self.fontSize = fontSize
        self.umlModel = umlModel
        determineChildren()
    }
    
    @MainActor
    func render(_ context: inout GraphicsContext, size: CGSize) {
        guard let model = self.umlModel,
              let modelType = model.type,
              !diagramTypeUnsupported else {
            return
        }
        let umlContext = UMLGraphicsContext(context, xOffset: 0, yOffset: 0)
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
    
    private func determineChildren() {
        guard let elements = umlModel?.elements else {
            log.warning("Could not find elements in the model")
            return
        }
        var potentialChildren = elements.filter({ $0.owner != nil })
        
        for (elementIndex, element) in elements.enumerated().reversed() {
            for (index, potentialChild) in potentialChildren.enumerated().reversed() where potentialChild.owner == element.id {
                elements[elementIndex].addChild(potentialChild)
                potentialChildren.remove(at: index)
            }
        }
        umlModel?.elements = elements
    }
}
