import SwiftUI
import ApollonShared

struct UMLUseCaseDiagramRenderer: UMLDiagramRenderer {
    var context: UMLGraphicsContext
    let canvasBounds: CGRect
    var fontSize: CGFloat = 14
    
    func render(umlModel: UMLModel) {
        let elementRenderer = UMLUseCaseDiagramElementRenderer(context: context, 
                                                               canvasBounds: canvasBounds,
                                                               fontSize: fontSize)
        let relationshipRenderer = UMLUseCaseDiagramRelationshipRenderer(context: context, 
                                                                         canvasBounds: canvasBounds,
                                                                         fontSize: fontSize)
        elementRenderer.render(umlModel: umlModel)
        relationshipRenderer.render(umlModel: umlModel)
    }
}
