import SwiftUI
import ApollonShared

struct UMLComponentDiagramElementRenderer: UMLDiagramRenderer {
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
            if element.value.type == .componentSubsystem {
                draw(element: element.value)
            }
        }

        for element in elements {
            if element.value.type == .component {
                draw(element: element.value)
            }
        }

        for element in elements {
            if element.value.type == .componentInterface {
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
        case .component, .componentSubsystem:
            drawComponentOrSubsystem(element: element, elementRect: elementRect)
        case .componentInterface:
            drawComponentInterface(element: element, elementRect: elementRect)
        default:
            drawUnknownElement(element: element, elementRect: elementRect)
        }
    }

    private func drawComponentOrSubsystem(element: UMLElement, elementRect: CGRect) {
        context.fill(Path(elementRect), with: .color(Color(UIColor.systemBackground)))
        context.stroke(Path(elementRect), with: .color(Color.primary))

        drawSmallComponentBox(element: element, elementRect: elementRect)

        drawTitle(of: element, in: elementRect)
    }

    private func drawComponentInterface(element: UMLElement, elementRect: CGRect) {
        var circlePath = Path()
        circlePath.addEllipse(in: elementRect)

        context.fill(circlePath, with: .color(Color(UIColor.systemBackground)))
        context.stroke(circlePath, with: .color(Color.primary))

        drawTitle(of: element, in: elementRect)
    }

    private func drawUnknownElement(element: UMLElement, elementRect: CGRect) {
        log.warning("Drawing logic for elements of type \(element.type?.rawValue ?? "nil") is not implemented")
        context.stroke(Path(elementRect), with: .color(Color.secondary))
    }

    private func drawSmallComponentBox(element: UMLElement, elementRect: CGRect) {
        let boxSize = CGSize(width: 20.0, height: 25.0)
        let boxOrigin = CGPoint(x: elementRect.maxX - boxSize.width - 10.0, y: elementRect.minY + 10.0)

        let boxPath = Path(CGRect(origin: boxOrigin, size: boxSize))
        context.stroke(boxPath, with: .color(Color.primary))

        let connectorBoxSize = CGSize(width: 10.0, height: 5.0)
        let connectorBoxOffsetX = connectorBoxSize.width / 2
        let connectorBoxY1 = boxOrigin.y + connectorBoxSize.height
        let connectorBoxY2 = boxOrigin.y + (connectorBoxSize.height * 3)

        let connectorBoxPath1 = Path(CGRect(x: boxOrigin.x - connectorBoxOffsetX, y: connectorBoxY1, width: connectorBoxSize.width, height: connectorBoxSize.height))
        context.fill(connectorBoxPath1, with: .color(Color(UIColor.systemBackground)))
        context.stroke(connectorBoxPath1, with: .color(Color.primary))

        let connectorBoxPath2 = Path(CGRect(x: boxOrigin.x - connectorBoxOffsetX, y: connectorBoxY2, width: connectorBoxSize.width, height: connectorBoxSize.height))
        context.fill(connectorBoxPath2, with: .color(Color(UIColor.systemBackground)))
        context.stroke(connectorBoxPath2, with: .color(Color.primary))
    }

    private func drawTitle(of element: UMLElement, in elementRect: CGRect) {
        var typeTextSize: CGSize = .zero

        if element.type == .component || element.type == .componentSubsystem {
            let typeTextString = element.type?.annotationTitle ?? ""
            var typeText = Text(typeTextString)
            typeText = typeText.font(.system(size: fontSize * 0.7, weight: .bold).monospaced())
            let typeResolved = context.resolve(typeText)
            typeTextSize = typeResolved.measure(in: elementRect.size)

            var typeRect: CGRect

            if element.type == .component {
                typeRect = CGRect(x: elementRect.midX - typeTextSize.width / 2,
                                  y: elementRect.midY - typeTextSize.height,
                                  width: typeTextSize.width,
                                  height: typeTextSize.height)
            } else {
                typeRect = CGRect(x: elementRect.midX - typeTextSize.width / 2,
                                  y: elementRect.minY + 10,
                                  width: typeTextSize.width,
                                  height: typeTextSize.height)
            }

            context.draw(typeResolved, in: typeRect)
        }

        var text = Text(element.name ?? "")
        text = text.font(.system(size: fontSize, weight: .bold))
        let elementTitle = context.resolve(text)
        let titleSize = elementTitle.measure(in: elementRect.size)

        var titleRect: CGRect

        switch element.type {
        case .component:
            titleRect = CGRect(x: elementRect.midX - titleSize.width / 2,
                               y: elementRect.midY,
                               width: titleSize.width,
                               height: titleSize.height)
        case .componentSubsystem:
            titleRect = CGRect(x: elementRect.midX - titleSize.width / 2,
                               y: elementRect.minY + typeTextSize.height + 10,
                               width: titleSize.width,
                               height: titleSize.height)
        case .componentInterface:
            titleRect = CGRect(x: elementRect.maxX + 5,
                               y: elementRect.minY - 15,
                               width: 120,
                               height: titleSize.height)
        default:
            titleRect = CGRect(x: elementRect.midX - titleSize.width / 2,
                               y: elementRect.midY,
                               width: titleSize.width,
                               height: titleSize.height)
        }

        context.draw(elementTitle, in: titleRect)
    }
}
