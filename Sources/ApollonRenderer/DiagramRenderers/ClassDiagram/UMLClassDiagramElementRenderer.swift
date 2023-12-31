//
//  UMLClassDiagramElementRenderer.swift
//
//  Created by Tarlan Ismayilsoy on 02.08.23.
//

import SwiftUI
import ApollonShared

struct UMLClassDiagramElementRenderer: UMLDiagramRenderer {
    var context: UMLGraphicsContext
    let canvasBounds: CGRect
    var fontSize: CGFloat
    
    func render(umlModel: UMLModel) {
        guard let elements = umlModel.elements else {
            log.error("The UML model contains no elements")
            return
        }
        
        // Hacky fix, to use 2 loops, as the elements dictionary is not sorted, so we need to render the attributes and methods after the other elements, or they will be hidden.
        for element in elements {
            if element.value.type == .package {
                draw(element: element.value)
            }
        }
        
        for element in elements {
            if [UMLElementType.Class, .abstractClass, .interface, .enumeration].contains(element.value.type) {
                draw(element: element.value)
            }
        }
        
        for element in elements {
            if [UMLElementType.classAttribute, .classMethod].contains(element.value.type) {
                draw(element: element.value)
            }
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
        case .Class, .abstractClass, .classMethod, .classAttribute, .enumeration, .interface:
            drawClassLikeElement(element: element, elementRect: elementRect)
        case .package:
            drawPackage(element: element, elementRect: elementRect)
        default:
            drawUnknownElement(element: element, elementRect: elementRect)
        }
    }
    
    private func drawClassLikeElement(element: UMLElement, elementRect: CGRect) {
        switch element.type {
        case .classAttribute, .classMethod:
            drawAttributeOrMethod(element, in: elementRect)
        default:
            drawTitle(of: element, in: elementRect)
        }
    }
    
    private func drawPackage(element: UMLElement, elementRect: CGRect) {
        
        let topCornerRect = CGRect(x: elementRect.minX,
                                   y: elementRect.minY,
                                   width: 45,
                                   height: 10)
        context.fill(Path(topCornerRect), with: .color(Color(UIColor.systemBackground)))
        context.stroke(Path(topCornerRect), with: .color(Color.primary))
        
        let newElementRect = CGRect(x: elementRect.minX,
                                    y: elementRect.minY + topCornerRect.height,
                                    width: elementRect.width,
                                    height: elementRect.height - topCornerRect.height)
        
        context.fill(Path(newElementRect), with: .color(Color(UIColor.systemBackground)))
        context.stroke(Path(newElementRect), with: .color(Color.primary))
        drawTitle(of: element, in: newElementRect)
    }
    
    private func drawUnknownElement(element: UMLElement, elementRect: CGRect) {
        log.warning("Drawing logic for elements of type \(element.type?.rawValue ?? "nil") is not implemented")
        context.stroke(Path(elementRect), with: .color(Color.secondary))
    }
    
    private func drawTitle(of element: UMLElement, in elementRect: CGRect) {
        var titleY: CGFloat
        
        context.fill(Path(elementRect), with: .color(Color(UIColor.systemBackground)))
        context.stroke(Path(elementRect), with: .color(Color.primary))
        
        // START: Draw type text
        let typeTextString = element.type?.annotationTitle ?? ""
        var typeText = Text(typeTextString)
        typeText = typeText.font(.system(size: fontSize * 0.7, weight: .bold).monospaced())
        let typeResolved = context.resolve(typeText)
        let typeTextSize = typeResolved.measure(in: elementRect.size)
        
        let typeRect = CGRect(x: elementRect.midX - typeTextSize.width / 2,
                              y: elementRect.minY + 5,
                              width: typeTextSize.width,
                              height: typeTextSize.height)
        context.draw(typeResolved, in: typeRect)
        // END: Draw type text
        
        titleY = typeTextString.isEmpty ? elementRect.minY + 5 : typeRect.maxY
        
        // START: Draw title text
        var text = Text(element.name ?? "")
        text = text.font(.system(size: fontSize, weight: .bold))
        
        if element.type == .abstractClass {
            text = text.italic()
        }
        
        let elementTitle = context.resolve(text)
        let titleSize = elementTitle.measure(in: elementRect.size)
        let titleRect = CGRect(x: elementRect.midX - titleSize.width / 2,
                               y: titleY,
                               width: titleSize.width,
                               height: titleSize.height)
        
        context.draw(elementTitle, in: titleRect)
        // END: Draw title text
        
        if [UMLElementType.Class, .abstractClass, .enumeration, .interface].contains(element.type) {
            drawAttributeAndMethodSeparators(element, in: elementRect)
        }
    }

    private func drawAttributeAndMethodSeparators(_ element: UMLElement, in elementRect: CGRect) {
        // Draw a line above the first attribute of this element
        if let firstAttribute = element.verticallySortedChildren?.first(where: { $0.type == .classAttribute }),
           let firstAttributeTopLeft = firstAttribute.boundsAsCGRect?.origin,
           let firstAttributeSize = firstAttribute.boundsAsCGRect?.size {
            let firstAttributeTopRight = firstAttributeTopLeft.applying(.init(translationX: firstAttributeSize.width, y: 0))
            
            var attributePath = Path()
            attributePath.move(to: firstAttributeTopLeft)
            attributePath.addLine(to: firstAttributeTopRight)
            
            context.stroke(attributePath, with: .color(.primary))
        }
        
        // Draw a line above the first method of this element
        if let firstMethod = element.verticallySortedChildren?.first(where: { $0.type == .classMethod }),
           let firstMethodTopLeft = firstMethod.boundsAsCGRect?.origin,
           let firstMethodSize = firstMethod.boundsAsCGRect?.size {
            let firstMethodTopRight = firstMethodTopLeft.applying(.init(translationX: firstMethodSize.width, y: 0))
            
            var methodPath = Path()
            methodPath.move(to: firstMethodTopLeft)
            methodPath.addLine(to: firstMethodTopRight)
            
            context.stroke(methodPath, with: .color(.primary))
        }
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
}
