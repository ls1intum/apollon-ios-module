import Foundation
import SwiftUI
import ApollonRenderer
import ApollonShared

@MainActor
open class ApollonEditViewModel: ApollonViewModel {
    @Published var selectedElement: SelectableUMLItem?
    @Published var selectedElementBounds: Boundary?
    @Published var geometrySize = CGSize.zero
    @Published var currentDragLocation = CGPoint.zero
    @Published var scale: CGFloat = 1.0
    @Published var progressingScale: CGFloat = 1.0
    @Published var idealScale: CGFloat = 1.0
    @Published var minScale: CGFloat = 0.2
    @Published var maxScale: CGFloat = 3.0
    @Published var initialDiagramSize: CGSize = .zero

    func setDragLocation(at point: CGPoint? = nil) {
        if let point {
            currentDragLocation = point
        } else {
            currentDragLocation = CGPoint(x: geometrySize.width / 2, y: geometrySize.height / 2)
        }
    }

    func setupScale(geometrySize: CGSize) {
        self.geometrySize = geometrySize
        self.initialDiagramSize = umlModel.size?.asCGSize ?? CGSize()
        calculateIdealScale()
        scale = idealScale
    }

    func calculateIdealScale() {
        if let size = umlModel.size {
            let scaleWidth = self.geometrySize.width / max(initialDiagramSize.width, size.width)
            let scaleHeight = self.geometrySize.height / max(initialDiagramSize.height, size.height)
            let initialScale = min(scaleWidth, scaleHeight)
            idealScale = min(max(initialScale, minScale), maxScale) - 0.05
        }
    }

    func adjustDiagramSizeForSelectedElement() {
        var largestXBottomRight: CGFloat = 0.0
        var largestYBottomRight: CGFloat = 0.0
        var smallestXTopLeft: CGFloat = 0.0
        var smallestYTopLeft: CGFloat = 0.0
        if let elements = umlModel.elements {
            for element in elements {
                if let bounds = element.value.bounds {
                    if bounds.x + bounds.width > largestXBottomRight {
                        largestXBottomRight = bounds.x + bounds.width
                    }
                    if bounds.y + bounds.height > largestYBottomRight {
                        largestYBottomRight = bounds.y + bounds.height
                    }
                    if bounds.x < smallestXTopLeft {
                        smallestXTopLeft = bounds.x
                    }
                    if bounds.y < smallestYTopLeft {
                        smallestYTopLeft = bounds.y
                    }
                }
            }
            umlModel.size?.width = largestXBottomRight + 1
            umlModel.size?.height = largestYBottomRight + 1

            if smallestXTopLeft < 0.0 || smallestYTopLeft < 0.0 {
                for elementOrigin in elements {
                    elementOrigin.value.bounds?.x += -(smallestXTopLeft)
                    elementOrigin.value.bounds?.y += -(smallestYTopLeft)
                }
                umlModel.size?.width += -(smallestXTopLeft) + 1
                umlModel.size?.height += -(smallestYTopLeft) + 1
            }
        }
    }

    func selectItem(at point: CGPoint) {
        self.selectedElement = getSelectableItem(at: point)
        self.selectedElementBounds = self.selectedElement?.bounds
    }

    private func getSelectableItem(at point: CGPoint) -> SelectableUMLItem? {
        /// Check for UMLRelationship
        if let relationship = umlModel.relationships?.first(where: { $0.value.boundsContains(point: point) }) {
            return relationship.value
        }
        /// Check for UMLElement
        if let elements = umlModel.elements {
            for element in elements where element.value.boundsContains(point: point) {
                if element.value.type?.isElementNotSelectable == true {
                    if let ownerName = element.value.owner {
                        return umlModel.elements?[ownerName]
                    }
                } else {
                    return element.value
                }
            }
        }
        return nil
    }

    func removeSelectedItem() {
        if let elements = umlModel.elements {
            for element in elements {
                if element.value.owner == selectedElement?.id {
                    umlModel.elements?.removeValue(forKey: element.key)
                }
            }

        }
        umlModel.elements?.removeValue(forKey: selectedElement?.id ?? "")
        if let relationships = umlModel.relationships {
            for relationship in relationships {
                if relationship.value.source?.element == selectedElement?.id || relationship.value.target?.element == selectedElement?.id {
                    umlModel.relationships?.removeValue(forKey: relationship.key)
                }
            }
        }
        umlModel.relationships?.removeValue(forKey: selectedElement?.id ?? "")
        selectedElement = nil
    }

    func updateElementPosition(location: CGPoint) {
        if let element = selectedElement as? UMLElement {
            selectedElement?.bounds?.x = location.x
            selectedElement?.bounds?.y = location.y
            if var offset = element.bounds?.height, let elements = umlModel.elements, let children = element.verticallySortedChildren {
                for child in children.reversed() {
                    for childElement in elements where child.id == childElement.value.id {
                        if let childBounds = childElement.value.bounds {
                            offset -= childBounds.height
                            umlModel.elements?[childElement.key]?.bounds?.x = location.x
                            umlModel.elements?[childElement.key]?.bounds?.y = location.y + offset
                        }
                    }
                }
            }
        }
    }

    func updateRelationshipPosition() {
        guard let relationships = umlModel.relationships else { return }

        for relationship in relationships {
            if let source = relationship.value.source,
               let target = relationship.value.target,
               let sourceDirection = source.direction,
               let targetDirection = target.direction,
               let sourceElement = getElementById(elementId: source.element ?? ""),
               let targetElement = getElementById(elementId: target.element ?? ""),
               let sourceBounds = sourceElement.bounds,
               let targetBounds = targetElement.bounds {

                // The points at which the relationship should start and end
                let sourcePortPoint = getPortsForElement(direction: sourceDirection, elementBounds: sourceBounds).add(PathPoint(x: sourceBounds.x, y: sourceBounds.y))
                let targetPortPoint = getPortsForElement(direction: targetDirection, elementBounds: targetBounds).add(PathPoint(x: targetBounds.x, y: targetBounds.y))

                // Calculates the new bounds of the relationship based on the previously calculated points
                let newBounds = calculateBoundaryAroundPoints(point1: targetPortPoint, point2: sourcePortPoint)
                relationship.value.bounds = newBounds

                var path: [PathPoint] = []

                // These are the starting and endpoints relative to the new bounding box
                let startPoint = PathPoint(x: sourcePortPoint.x - newBounds.x, y: sourcePortPoint.y - newBounds.y)
                let endPoint = PathPoint(x: targetPortPoint.x - newBounds.x, y: targetPortPoint.y - newBounds.y)

                // Use case diagrams use direct paths which can be diagonal, so no need to calculate the horizontal and vertical segments
                if diagramType == .useCaseDiagram {
                    path.append(startPoint)
                    path.append(endPoint)
                } else {
                    //
                    let startPointMargin = sourcePortPoint.add(getMarginPoint(direction: sourceDirection))
                    let endPointMargin = targetPortPoint.add(getMarginPoint(direction: targetDirection))

                    path.append(startPoint)
                    path.append(startPoint.add(getMarginPoint(direction: sourceDirection)))

                    // The variables help determine if the path segment should be horizontal or vertical
                    let dx = abs(targetPortPoint.x - sourcePortPoint.x)
                    let dy = abs(targetPortPoint.y - sourcePortPoint.y)

                    // Calculates if a horizontal or vertical path needs to be added and appends it to the path
                    // Positive stride step goes up and negative goes down
                    if dx >= dy {
                        // Horizontal path
                        let step = (endPointMargin.x > startPointMargin.x) ? 1 : -1
                        for x in stride(from: startPointMargin.x, to: endPointMargin.x, by: Double(step)) {
                            let y = startPointMargin.y // Keep y constant
                            path.append(PathPoint(x: x - newBounds.x, y: y - newBounds.y))
                        }
                    } else {
                        // Vertical path
                        let step = (endPointMargin.y > startPointMargin.y) ? 1 : -1
                        for y in stride(from: startPointMargin.y, to: endPointMargin.y, by: Double(step)) {
                            let x = startPointMargin.x // Keep x constant
                            path.append(PathPoint(x: x - newBounds.x, y: y - newBounds.y))
                        }
                    }

                    path.append(endPoint.add(getMarginPoint(direction: targetDirection)))
                    path.append(endPoint)
                }
                relationship.value.path = path
            }
        }
    }

    // Returns the point based on the direction of the relationship
    private func getPortsForElement(direction: Direction, elementBounds: Boundary) -> PathPoint {
        switch direction {
        case .up:
            return PathPoint(x: elementBounds.width / 2, y: 0)
        case .right:
            return PathPoint(x: elementBounds.width, y: elementBounds.height / 2)
        case .down:
            return PathPoint(x: elementBounds.width / 2, y: elementBounds.height)
        case .left:
            return PathPoint(x: 0, y: elementBounds.height / 2)
        case .upRight:
            return PathPoint(x: elementBounds.width, y: elementBounds.height / 4)
        case .downRight:
            return PathPoint(x: elementBounds.width, y: (3 * elementBounds.height) / 4)
        case .upLeft:
            return PathPoint(x: 0, y: elementBounds.height / 4)
        case .downLeft:
            return PathPoint(x: 0, y: (3 * elementBounds.height) / 4)
        case .topRight:
            return PathPoint(x: (3 * elementBounds.width) / 4, y: 0)
        case .bottomRight:
            return PathPoint(x: (3 * elementBounds.width) / 4, y: elementBounds.height)
        case .topLeft:
            return PathPoint(x: elementBounds.width / 4, y: 0)
        case .bottomLeft:
            return PathPoint(x: elementBounds.width / 4, y: elementBounds.height)
        }
    }

    // This returns the second point or second last point of the path which we call the margin point
    private func getMarginPoint(direction: Direction) -> PathPoint {
        let ENTITY_MARGIN = 40.0
        switch direction {
        case .up, .topRight, .topLeft:
            return PathPoint(x: 0, y: -ENTITY_MARGIN)
        case .right, .upRight, .downRight:
            return PathPoint(x: ENTITY_MARGIN, y: 0)
        case .down, .bottomRight, .bottomLeft:
            return PathPoint(x: 0, y: ENTITY_MARGIN)
        case .left, .upLeft, .downLeft:
            return PathPoint(x: -ENTITY_MARGIN, y: 0)
        }
    }

    private func calculateBoundaryAroundPoints(point1: PathPoint, point2: PathPoint) -> Boundary {
        return Boundary(x: min(point1.x, point2.x), y: min(point1.y, point2.y), width: abs(point2.x - point1.x), height: abs(point2.y - point1.y))
    }

    func updateElementSize(drag: CGSize) {
        if let element = selectedElement as? UMLElement {
            selectedElement?.bounds?.width += drag.width
            selectedElement?.bounds?.height += drag.height
            if let children = element.verticallySortedChildren {
                for child in children {
                    child.bounds?.width += drag.width
                    child.bounds?.height += drag.height
                }
            }
        }
    }

    func addElement(type: UMLElementType) {
        let middle = CGPoint(x: (umlModel.size?.width ?? 1) / 2, y: (umlModel.size?.height ?? 1) / 2)
        let elementCreator = ElementCreatorFactory.createElementCreator(for: type)
        if let elementCreator {
            let elementsToAdd = elementCreator.createAllElements(for: type, middle: middle)
            for element in elementsToAdd {
                if let elementId = element.id {
                    umlModel.elements?[elementId] = element
                }
            }
        } else {
            log.error("Attempted to create an unknown element")
        }
    }

    func getElementById(elementId: String) -> UMLElement? {
        if let element = umlModel.elements?.first(where: { $0.key == elementId }) {
            return element.value
        }
        return nil
    }

    func getElementTypeById(elementId: String) -> UMLElementType? {
        if let element = umlModel.elements?.first(where: { $0.key == elementId }) {
            return element.value.type ?? nil
        }
        return nil
    }
}
