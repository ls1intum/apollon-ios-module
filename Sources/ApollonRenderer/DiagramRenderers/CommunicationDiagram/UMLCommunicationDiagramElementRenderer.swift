import SwiftUI
import ApollonShared

struct UMLCommunicationDiagramElementRenderer: UMLDiagramRenderer {
    var context: UMLGraphicsContext
    let canvasBounds: CGRect
    var fontSize: CGFloat
    
    func render(umlModel: UMLModel) {
        guard let elements = umlModel.elements else {
            log.error("The UML model contains no elements")
            return
        }
        
        for element in elements {
            draw(element: element)
        }
    }
    
    private func draw(element: UMLElement) {
        guard let xCoordinate = element.bounds?.x,
              let yCoordinate = element.bounds?.y,
              let width = element.bounds?.width,
              let height = element.bounds?.height else {
            log.warning("Failed to draw a UML element: \(element)")
            return
        }
        
        let elementRect = CGRect(x: xCoordinate, y: yCoordinate, width: width, height: height)
        
        switch element.type {
        case .objectName, .objectAttribute, .objectMethod:
            drawObjectElement(element: element, elementRect: elementRect)
        default:
            drawUnknownElement(element: element, elementRect: elementRect)
        }
    }
    
    private func drawObjectElement(element: UMLElement, elementRect: CGRect) {
        switch element.type {
        case .objectAttribute, .objectMethod:
            drawAttributeOrMethod(element, in: elementRect)
        default:
            drawTitle(of: element, in: elementRect)
        }
    }
    
    private func drawUnknownElement(element: UMLElement, elementRect: CGRect) {
        log.warning("Drawing logic for elements of type \(element.type?.rawValue ?? "nil") is not implemented")
        context.stroke(Path(elementRect), with: .color(Color.secondary))
    }
    
    private func drawAttributeOrMethod(_ element: UMLElement, in elementRect: CGRect) {
        var text = Text(element.name ?? "")
        text = text.font(.system(size: fontSize))
        
        let elementTitle = context.resolve(text)
        let titleSize = elementTitle.measure(in: elementRect.size)
        let titleRect = CGRect(x: elementRect.minX + 5,
                               y: elementRect.midY - titleSize.height / 2,
                               width: titleSize.width,
                               height: titleSize.height)
        
        context.draw(elementTitle, in: titleRect)
    }
    
    private func drawTitle(of element: UMLElement, in elementRect: CGRect) {
        context.fill(Path(elementRect), with: .color(Color(UIColor.systemBackground)))
        context.stroke(Path(elementRect), with: .color(Color.primary))
        
        var text = Text(element.name ?? "")
        text = text.font(.system(size: fontSize, weight: .bold)).underline()
        
        let elementTitle = context.resolve(text)
        let titleSize = elementTitle.measure(in: elementRect.size)
        let titleRect = CGRect(x: elementRect.midX - titleSize.width / 2,
                               y: elementRect.minY + 10,
                               width: titleSize.width,
                               height: titleSize.height)
        
        context.draw(elementTitle, in: titleRect)
        
        if [UMLElementType.objectName].contains(element.type) {
            drawAttributeAndMethodSeparators(element, in: elementRect)
        }
    }
    
    private func drawAttributeAndMethodSeparators(_ element: UMLElement, in elementRect: CGRect) {
        // Draw a line above the first attribute of this element
        if let firstAttribute = element.verticallySortedChildren?.first(where: { $0.type == .objectAttribute }),
           let firstAttributeTopLeft = firstAttribute.boundsAsCGRect?.origin,
           let firstAttributeSize = firstAttribute.boundsAsCGRect?.size {
            let firstAttributeTopRight = firstAttributeTopLeft.applying(.init(translationX: firstAttributeSize.width, y: 0))
            
            var attributePath = Path()
            attributePath.move(to: firstAttributeTopLeft)
            attributePath.addLine(to: firstAttributeTopRight)
            
            context.stroke(attributePath, with: .color(.primary))
        }
        
        // Draw a line above the first method of this element
        if let firstMethod = element.verticallySortedChildren?.first(where: { $0.type == .objectMethod }),
           let firstMethodTopLeft = firstMethod.boundsAsCGRect?.origin,
           let firstMethodSize = firstMethod.boundsAsCGRect?.size {
            let firstMethodTopRight = firstMethodTopLeft.applying(.init(translationX: firstMethodSize.width, y: 0))
            
            var methodPath = Path()
            methodPath.move(to: firstMethodTopLeft)
            methodPath.addLine(to: firstMethodTopRight)
            
            context.stroke(methodPath, with: .color(.primary))
        }
    }
}
