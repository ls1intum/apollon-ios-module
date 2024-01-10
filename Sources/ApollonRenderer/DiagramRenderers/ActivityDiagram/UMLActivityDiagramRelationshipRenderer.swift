import SwiftUI
import ApollonShared

struct UMLActivityDiagramRelationshipRenderer: UMLDiagramRenderer {
    var context: UMLGraphicsContext
    let canvasBounds: CGRect
    var fontSize: CGFloat
    
    func render(umlModel: UMLModel) {
        guard let relationships = umlModel.relationships else {
            log.warning("The UML model contains no relationships")
            return
        }
        
        for relationship in relationships {
            draw(relationship: relationship.value)
        }
    }
    
    private func draw(relationship: UMLRelationship) {
        guard let relationshipRect = relationship.boundsAsCGRect else {
            log.warning("Failed to draw a UML relationship: \(relationship)")
            return
        }
        
        switch relationship.type {
        case .activityControlFlow:
            drawControlFlow(relationship, in: relationshipRect)
        default:
            drawUnknown(relationship, in: relationshipRect)
        }
    }
    
    private func drawControlFlow(_ relationship: UMLRelationship, in relationshipRect: CGRect) {
        guard let path = relationship.pathWithCGPoints else {
            return
        }
        
        context.stroke(path, with: .color(Color.primary))
        drawControlFlowTitleText(for: relationship, on: path)
        drawControlFlowHead(for: relationship, on: path)
    }
    
    private func drawUnknown(_ relationship: UMLRelationship, in relationshipRect: CGRect) {
        drawControlFlow(relationship, in: relationshipRect)
    }
    
    private func drawControlFlowTitleText(for relationship: UMLRelationship, on path: Path) {
        guard let relationshipRect = relationship.boundsAsCGRect,
              let relationshipName = relationship.name else {
            log.warning("Could not draw type text for: \(relationship)")
            return
        }
        
        let text = Text(relationshipName).font(.system(size: fontSize))
        let resolvedText = context.resolve(text)
        let textSize = resolvedText.measure(in: canvasBounds.size)
        let textRect = CGRect(x: relationshipRect.midX - textSize.width / 2,
                              y: relationshipRect.midY - textSize.height / 2,
                              width: textSize.width,
                              height: textSize.height)
        
        context.draw(resolvedText, in: textRect)
    }
    
    private func drawControlFlowHead(for relationship: UMLRelationship, on path: Path) {
        guard let endPoint = path.currentPoint,
              let arrowTargetDirection = relationship.target?.direction?.inverted else {
            log.warning("Could not draw arrowhead for: \(relationship)")
            return
        }
        
        let size: CGFloat = 10.0
        var path = Path()
        
        path.move(to: .init(x: endPoint.x - size, y: endPoint.y + size * 1.5))
        path.addLine(to: .init(x: endPoint.x, y: endPoint.y))
        path.addLine(to: .init(x: endPoint.x + size, y: endPoint.y + size * 1.5))
        
        switch arrowTargetDirection {
        case .up, .topLeft, .topRight:
            path = path.offsetBy(dx: 0, dy: size * 0.15)
        case .down, .downRight:
            path = path.rotation(.degrees(180)).path(in: path.boundingRect)
            path = path.offsetBy(dx: 0, dy: size * -1.6)
        case .right, .upRight, .bottomLeft:
            path = path.rotation(.degrees(90)).path(in: path.boundingRect)
            path = path.offsetBy(dx: size * -0.8, dy: size * -0.75)
        case .left, .upLeft, .downLeft, .bottomRight:
            path = path.rotation(.degrees(-90)).path(in: path.boundingRect)
            path = path.offsetBy(dx: size * 0.8, dy: size * -0.75)
        }
        
        context.stroke(path, with: .color(Color.primary))
    }
}
