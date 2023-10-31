import SwiftUI
import ApollonShared

struct UMLCommunicationDiagramRenderer: UMLDiagramRenderer {
    var context: UMLGraphicsContext
    let canvasBounds: CGRect
    var fontSize: CGFloat = 14
    
    func render(umlModel: UMLModel) {
        let elementRenderer = UMLCommunicationDiagramElementRenderer(context: context,
                                                             canvasBounds: canvasBounds,
                                                             fontSize: fontSize)
        let relationshipRenderer = UMLCommunicationDiagramRelationshipRenderer(context: context,
                                                                       canvasBounds: canvasBounds,
                                                                       fontSize: fontSize)
        elementRenderer.render(umlModel: umlModel)
        relationshipRenderer.render(umlModel: umlModel)
    }
}
