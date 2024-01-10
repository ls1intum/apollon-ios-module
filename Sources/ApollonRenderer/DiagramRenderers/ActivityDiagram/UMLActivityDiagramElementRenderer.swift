import SwiftUI
import ApollonShared

struct UMLActivityDiagramElementRenderer: UMLDiagramRenderer {
    var context: UMLGraphicsContext
    let canvasBounds: CGRect
    var fontSize: CGFloat

    func render(umlModel: UMLModel) {
        guard let elements = umlModel.elements else {
            log.error("The UML model contains no elements")
            return
        }

        // Hacky fix, to use 2 loops, as the elements dictionary is not sorted, so we need to render the children after containers, or they will be hidden.
        for element in elements {
            if element.value.type == .activity {
                draw(element: element.value)
            }
        }

        for element in elements {
            if element.value.type != .activity {
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
        case .activityInitialNode:
            drawInitialNode(element: element, elementRect: elementRect)
        case .activity, .activityActionNode:
            drawActivityOrAction(element: element, elementRect: elementRect)
        case .activityObjectNode:
            drawObject(element: element, elementRect: elementRect)
        case .activityMergeNode:
            drawMerge(element: element, elementRect: elementRect)
        case .activityForkNode, .activityForkNodeHorizontal:
            drawForkNode(element: element, elementRect: elementRect)
        case .activityFinalNode:
            drawFinalNode(element: element, elementRect: elementRect)
        default:
            drawUnknownElement(element: element, elementRect: elementRect)
        }
    }

    private func drawInitialNode(element: UMLElement, elementRect: CGRect) {
        var circlePath = Path()
        circlePath.addEllipse(in: elementRect)

        context.fill(circlePath, with: .color(Color.primary))
    }

    private func drawFinalNode(element: UMLElement, elementRect: CGRect) {
        // Draw the outer circle
        var outerCirclePath = Path()
        outerCirclePath.addEllipse(in: elementRect)
        context.fill(outerCirclePath, with: .color(Color.primary))

        // Draw the middle circle
        let middlePadding: CGFloat = 5.0
        let middleCircleRect = elementRect.insetBy(dx: middlePadding, dy: middlePadding)
        var middleCirclePath = Path()
        middleCirclePath.addEllipse(in: middleCircleRect)
        context.fill(middleCirclePath, with: .color(Color(UIColor.systemBackground)))

        // Draw the inner circle
        let innerPadding: CGFloat = 8.0
        let innerCircleRect = elementRect.insetBy(dx: innerPadding, dy: innerPadding)
        var innerCirclePath = Path()
        innerCirclePath.addEllipse(in: innerCircleRect)
        context.fill(innerCirclePath, with: .color(Color.primary))
    }

    private func drawActivityOrAction(element: UMLElement, elementRect: CGRect) {
        let roundedRectPath = Path(roundedRect: elementRect, cornerRadius: 10)

        context.fill(roundedRectPath, with: .color(Color(UIColor.systemBackground)))
        context.stroke(roundedRectPath, with: .color(Color.primary))

        drawTitle(of: element, in: elementRect)
    }

    private func drawObject(element: UMLElement, elementRect: CGRect) {
        context.fill(Path(elementRect), with: .color(Color(UIColor.systemBackground)))
        context.stroke(Path(elementRect), with: .color(Color.primary))

        drawTitle(of: element, in: elementRect)
    }

    private func drawMerge(element: UMLElement, elementRect: CGRect) {
        var diamondPath = Path()

        diamondPath.move(to: CGPoint(x: elementRect.midX, y: elementRect.minY))
        diamondPath.addLine(to: CGPoint(x: elementRect.maxX, y: elementRect.midY))
        diamondPath.addLine(to: CGPoint(x: elementRect.midX, y: elementRect.maxY))
        diamondPath.addLine(to: CGPoint(x: elementRect.minX, y: elementRect.midY))
        diamondPath.addLine(to: CGPoint(x: elementRect.midX, y: elementRect.minY))

        context.fill(diamondPath, with: .color(Color(UIColor.systemBackground)))
        context.stroke(diamondPath, with: .color(Color.primary))

        drawTitle(of: element, in: elementRect)
    }

    private func drawForkNode(element: UMLElement, elementRect: CGRect) {
        context.fill(Path(elementRect), with: .color(Color.primary))
    }

    private func drawUnknownElement(element: UMLElement, elementRect: CGRect) {
        log.warning("Drawing logic for elements of type \(element.type?.rawValue ?? "nil") is not implemented")
        context.stroke(Path(elementRect), with: .color(Color.secondary))
    }

    private func drawTitle(of element: UMLElement, in elementRect: CGRect) {
        var text = Text(element.name ?? "")
        text = text.font(.system(size: fontSize, weight: .bold))
        let elementTitle = context.resolve(text)
        let titleSize = elementTitle.measure(in: elementRect.size)

        var titleRect: CGRect

        switch element.type {
        case .activity:
            titleRect = CGRect(x: elementRect.midX - titleSize.width / 2,
                               y: elementRect.minY + 10,
                               width: titleSize.width,
                               height: titleSize.height)
        case .activityActionNode, .activityObjectNode, .activityMergeNode:
            titleRect = CGRect(x: elementRect.midX - titleSize.width / 2,
                               y: elementRect.midY - titleSize.height / 2,
                               width: titleSize.width,
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
