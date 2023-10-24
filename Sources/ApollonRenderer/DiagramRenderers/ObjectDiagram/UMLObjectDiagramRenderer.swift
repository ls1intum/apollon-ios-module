import SwiftUI
import ApollonShared

struct UMLObjectDiagramRenderer: UMLDiagramRenderer {
    var context: UMLGraphicsContext
    let canvasBounds: CGRect
    var fontSize: CGFloat = 14
    
    func render(umlModel: UMLModel) {
        let elementRenderer = UMLObjectDiagramElementRenderer(context: context,
                                                             canvasBounds: canvasBounds,
                                                             fontSize: fontSize)
        let relationshipRenderer = UMLObjectDiagramRelationshipRenderer(context: context,
                                                                       canvasBounds: canvasBounds,
                                                                       fontSize: fontSize)
        elementRenderer.render(umlModel: umlModel)
        relationshipRenderer.render(umlModel: umlModel)
    }
}
