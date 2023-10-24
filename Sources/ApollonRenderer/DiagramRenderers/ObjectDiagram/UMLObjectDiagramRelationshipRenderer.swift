import SwiftUI
import ApollonShared

struct UMLObjectDiagramRelationshipRenderer: UMLDiagramRenderer {
    var context: UMLGraphicsContext
    let canvasBounds: CGRect
    var fontSize: CGFloat
    
    func render(umlModel: UMLModel) {
        guard let relationships = umlModel.relationships else {
            log.warning("The UML model contains no relationships")
            return
        }
        
        for relationship in relationships {
            draw(relationship: relationship)
        }
    }
    
    private func draw(relationship: UMLRelationship) {
        guard let relationshipRect = relationship.boundsAsCGRect else {
            log.warning("Failed to draw a UML relationship: \(relationship)")
            return
        }
        
        switch relationship.type {
        case .objectLink:
            drawObjectLink(relationship, in: relationshipRect)
        default:
            drawUnknown(relationship, in: relationshipRect)
        }
    }
    
    private func drawObjectLink(_ relationship: UMLRelationship, in relationshipRect: CGRect) {
        guard let path = relationship.pathWithCGPoints else {
            return
        }
        context.stroke(path, with: .color(Color.primary))
    }
    
    private func drawUnknown(_ relationship: UMLRelationship, in relationshipRect: CGRect) {
        log.warning("Drawing logic for relationships of type \(relationship.type?.rawValue ?? "nil") is not implemented")
        drawObjectLink(relationship, in: relationshipRect)
    }
}
