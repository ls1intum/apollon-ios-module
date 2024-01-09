import SwiftUI
import ApollonShared

struct UMLComponentDiagramRelationshipRenderer: UMLDiagramRenderer {
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
        case .componentDependency:
            drawComponentDependency(relationship, in: relationshipRect)
        case .componentInterfaceProvided, .componentInterfaceRequired:
            drawComponentInterfaceProvidedOrRequired(relationship, in: relationshipRect)
        default:
            drawUnknown(relationship, in: relationshipRect)
        }
    }

    private func drawComponentDependency(_ relationship: UMLRelationship, in relationshipRect: CGRect) {
        guard let path = relationship.pathWithCGPoints else {
            return
        }

        context.stroke(path, with: .color(Color.primary), style: .init(dash: [7, 7]))
        drawComponentHead(for: relationship, on: path)
    }

    private func drawComponentInterfaceProvidedOrRequired(_ relationship: UMLRelationship, in relationshipRect: CGRect) {
        guard let path = relationship.pathWithCGPoints else {
            return
        }

        context.stroke(path, with: .color(Color.primary))
        drawComponentHead(for: relationship, on: path)
    }

    private func drawUnknown(_ relationship: UMLRelationship, in relationshipRect: CGRect) {
        drawComponentDependency(relationship, in: relationshipRect)
    }

    private func drawComponentHead(for relationship: UMLRelationship, on path: Path) {
        guard let endPoint = path.currentPoint,
              let arrowTargetDirection = relationship.target?.direction else {
            log.warning("Could not draw arrowhead for: \(relationship)")
            return
        }

        var type: ComponentHeadType

        switch relationship.type {
        case .componentDependency:
            type = .triangleWithoutBase
        case .componentInterfaceProvided:
            return // Interface Provided has no head
        case .componentInterfaceRequired:
            type = .halfCircle
        default:
            type = .triangleWithoutBase
        }

        drawComponentHead(at: endPoint, lookingAt: arrowTargetDirection.inverted, type: type)
    }

    private func drawComponentHead(at point: CGPoint, lookingAt direction: Direction, type: ComponentHeadType) {
        var path = Path()

        switch type {
        case .triangleWithoutBase:
            let size: CGFloat = 10.0
            path.move(to: .init(x: point.x - size, y: point.y + size * 1.5))
            path.addLine(to: .init(x: point.x, y: point.y))
            path.addLine(to: .init(x: point.x + size, y: point.y + size * 1.5))
            switch direction {
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
        case .halfCircle:
            let size: CGFloat = 15.0
            switch direction {
            case .up, .topLeft, .topRight:
                path.addArc(center: CGPoint(x: point.x, y: point.y - 10.0),
                            radius: size,
                            startAngle: Angle(degrees: 150),
                            endAngle: Angle(degrees: 30),
                            clockwise: true)
            case .down, .downRight:
                path.addArc(center: CGPoint(x: point.x, y: point.y + 10.0),
                            radius: size,
                            startAngle: Angle(degrees: 330),
                            endAngle: Angle(degrees: 210),
                            clockwise: true)
            case .right, .upRight, .bottomLeft:
                path.addArc(center: CGPoint(x: point.x + 10.0, y: point.y),
                            radius: size,
                            startAngle: Angle(degrees: 240),
                            endAngle: Angle(degrees: 120),
                            clockwise: true)
            case .left, .upLeft, .downLeft, .bottomRight:
                path.addArc(center: CGPoint(x: point.x - 10.0, y: point.y),
                            radius: size,
                            startAngle: Angle(degrees: 60),
                            endAngle: Angle(degrees: 300),
                            clockwise: true)
            }
            context.stroke(path, with: .color(Color.primary), lineWidth: 5)
        }
    }
}

private enum ComponentHeadType {
    case triangleWithoutBase, halfCircle
}
