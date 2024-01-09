import SwiftUI
import ApollonShared

struct UMLComponentDiagramRenderer: UMLDiagramRenderer {
    var context: UMLGraphicsContext
    let canvasBounds: CGRect
    var fontSize: CGFloat = 14

    func render(umlModel: UMLModel) {
        let elementRenderer = UMLComponentDiagramElementRenderer(context: context,
                                                            canvasBounds: canvasBounds,
                                                            fontSize: fontSize)
        let relationshipRenderer = UMLComponentDiagramRelationshipRenderer(context: context,
                                                                   canvasBounds: canvasBounds,
                                                                   fontSize: fontSize)
        elementRenderer.render(umlModel: umlModel)
        relationshipRenderer.render(umlModel: umlModel)
    }
}
