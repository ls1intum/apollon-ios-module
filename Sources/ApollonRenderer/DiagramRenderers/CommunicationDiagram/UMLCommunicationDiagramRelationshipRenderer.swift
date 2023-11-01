import SwiftUI
import ApollonShared

struct UMLCommunicationDiagramRelationshipRenderer: UMLDiagramRenderer {
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
        case .communicationLink:
            drawCommunicationLink(relationship, in: relationshipRect)
        default:
            drawUnknown(relationship, in: relationshipRect)
        }
    }
    
    private func drawCommunicationLink(_ relationship: UMLRelationship, in relationshipRect: CGRect) {
        guard let path = relationship.pathWithCGPoints else {
            return
        }
        context.stroke(path, with: .color(Color.primary))
        if let messages = relationship.messages {
            drawMessages(relationship, messages: messages, in: relationshipRect)
        }
    }
    
    private func drawUnknown(_ relationship: UMLRelationship, in relationshipRect: CGRect) {
        log.warning("Drawing logic for relationships of type \(relationship.type?.rawValue ?? "nil") is not implemented")
        drawCommunicationLink(relationship, in: relationshipRect)
    }
    
    private func drawMessages(_ relationship: UMLRelationship, messages: [String : UMLElement], in relationshipRect: CGRect) {
        let sourceMessages = messages.values.filter({ $0.direction == .source })
        let targetMessages = messages.values.filter({ $0.direction == .target })
        
        if !sourceMessages.isEmpty {
            for sourceMessage in sourceMessages {
                drawMessageText(sourceMessage, in: relationshipRect)
            }
            drawDirectionArrow(relationship, firstMessageBounds: sourceMessages.first?.bounds, elementDirection: .source, in: relationshipRect)
        }
        
        if !targetMessages.isEmpty {
            for targetMessage in targetMessages {
                drawMessageText(targetMessage, in: relationshipRect)
            }
            drawDirectionArrow(relationship, firstMessageBounds: targetMessages.first?.bounds, elementDirection: .target, in: relationshipRect)
        }
    }
    
    private func drawMessageText(_ message: UMLElement, in relationshipRect: CGRect) {
        let roleText = Text(message.name ?? "").font(.system(size: fontSize))
        let resolvedText = context.resolve(roleText)
        let textSize = resolvedText.measure(in: canvasBounds.size)
        
        let xPosition: CGFloat = relationshipRect.minX + (message.bounds?.x ?? 0)
        let yPosition: CGFloat = relationshipRect.minY + (message.bounds?.y ?? 0)
        
        let textRect = CGRect(x: xPosition, y: yPosition, width: textSize.width, height: textSize.height)
        context.draw(resolvedText, in: textRect)
    }
    
    // TODO: FIX THE FUNCTION (NOT WORKING AS EXPECTED)
    private func drawDirectionArrow(_ relationship: UMLRelationship, firstMessageBounds: Boundary?, elementDirection: ElementDirection, in relationshipRect: CGRect) {
        guard let path = relationship.path else {
            return
        }
        
        var position = PathPoint(x: 0, y: 0)
        var direction: Direction = .left
        
        var distance: CGFloat = 0.0
    
        for index in 0..<(path.count - 1) {
            distance += sqrt(path[index].distanceToSquared(path[index + 1]))
        }
        
        distance = distance / 2
        
        for index in 0..<(path.count - 1) {
            let vector = path[index + 1].subtract(path[index])
            if vector.length() > distance {
                let norm = vector.normalize()
                if abs(norm.x) > abs(norm.y) {
                    direction = norm.x > 0 ? .left : .right
                } else {
                    direction = norm.y > 0 ? .up : .down
                }
                position = path[index].add(norm.scale(distance))
                break
            }
            distance -= vector.length()
        }
        
        var xPosition: CGFloat = relationshipRect.minX + position.x
        var yPosition: CGFloat = relationshipRect.minY + position.y
        var arrowIcon: String = ""
        
        switch direction {
        case .up:
            if elementDirection == .source {
                xPosition += 8
                arrowIcon = "↓"
            } else if elementDirection == .target {
                xPosition -= 16
                arrowIcon = "↑"
            }
        case .down:
            if elementDirection == .source {
                xPosition -= 16
                arrowIcon = "↑"
            } else if elementDirection == .target {
                xPosition += 8
                arrowIcon = "↓"
            }
        case .left:
            if elementDirection == .source {
                arrowIcon = "⟶"
            } else if elementDirection == .target {
                yPosition += 16
                arrowIcon = "⟵"
            }
        case .right:
            if elementDirection == .source {
                yPosition += 16
                arrowIcon = "⟵"
            } else if elementDirection == .target {
                arrowIcon = "⟶"
            }
        default:
            break
        }
        
        let messageText = Text(arrowIcon).font(.system(size: fontSize))
        let resolvedText = context.resolve(messageText)
        let textSize = resolvedText.measure(in: canvasBounds.size)
        
        let textRect = CGRect(x: xPosition, y: yPosition, width: textSize.width, height: 10)
        context.draw(resolvedText, in: textRect)
    }
}
