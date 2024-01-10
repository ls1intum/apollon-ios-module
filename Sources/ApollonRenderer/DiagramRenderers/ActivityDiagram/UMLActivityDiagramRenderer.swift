import SwiftUI
import ApollonShared

struct UMLActivityDiagramRenderer: UMLDiagramRenderer {
    var context: UMLGraphicsContext
    let canvasBounds: CGRect
    var fontSize: CGFloat = 14

    func render(umlModel: UMLModel) {
        let elementRenderer = UMLActivityDiagramElementRenderer(context: context,
                                                            canvasBounds: canvasBounds,
                                                            fontSize: fontSize)
        let relationshipRenderer = UMLActivityDiagramRelationshipRenderer(context: context,
                                                                   canvasBounds: canvasBounds,
                                                                   fontSize: fontSize)
        elementRenderer.render(umlModel: umlModel)
        relationshipRenderer.render(umlModel: umlModel)
    }
}
