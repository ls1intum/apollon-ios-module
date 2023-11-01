import SwiftUI
import ApollonShared

struct UMLObjectDiagramElementRenderer: UMLDiagramRenderer {
    var context: UMLGraphicsContext
    let canvasBounds: CGRect
    var fontSize: CGFloat
    
    func render(umlModel: UMLModel) {
        guard let elements = umlModel.elements else {
            log.error("The UML model contains no elements")
            return
        }
        
        for element in elements {
            if element.value.type == .objectName {
                drawTitle(of: element.value)
            }
        }
    }
    
    private func drawTitle(of element: UMLElement) {
        guard let elementRect = element.boundsAsCGRect else {
            log.warning("Failed to draw a UML element: \(element)")
            return
        }
        
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
        
        if let children = element.verticallySortedChildren {
            for child in children {
                drawAttributeOrMethod(child)
            }
        }
        drawAttributeAndMethodSeparators(element, in: elementRect)
    }
    
    private func drawAttributeOrMethod(_ element: UMLElement) {
        guard let elementRect = element.boundsAsCGRect else {
            log.warning("Failed to draw a UML element: \(element)")
            return
        }
        
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
