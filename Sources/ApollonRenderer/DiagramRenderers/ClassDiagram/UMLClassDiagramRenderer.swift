import SwiftUI
import ApollonShared

struct UMLClassDiagramRenderer: UMLDiagramRenderer {
    var context: UMLGraphicsContext
    let canvasBounds: CGRect
    var fontSize: CGFloat = 14
    
    func render(umlModel: UMLModel) {
        let elementRenderer = UMLClassDiagramElementRenderer(context: context,
                                                             canvasBounds: canvasBounds,
                                                             fontSize: fontSize)
        let relationshipRenderer = UMLClassDiagramRelationshipRenderer(context: context,
                                                                       canvasBounds: canvasBounds,
                                                                       fontSize: fontSize)
        elementRenderer.render(umlModel: umlModel)
        relationshipRenderer.render(umlModel: umlModel)
    }
}
