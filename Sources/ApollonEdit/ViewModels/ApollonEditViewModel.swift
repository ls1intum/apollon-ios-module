import Foundation
import SwiftUI
import ApollonRenderer
import ApollonShared

@MainActor
open class ApollonEditViewModel: ApollonViewModel {
    @Published var selectedElement: SelectableUMLItem?
    @Published var selectedElementBounds: Boundary?

    /// Return the selected Item based on a given Point
    func selectItem(at point: CGPoint) {
        self.selectedElement = getSelectableItem(at: point)
        self.selectedElementBounds = self.selectedElement?.bounds
    }

    /// Helper function for selectItem()
    private func getSelectableItem(at point: CGPoint) -> SelectableUMLItem? {
        // Check for UMLRelationship
        if let relationship = umlModel.relationships?.first(where: { $0.value.boundsContains(point: point) }) {
            return relationship.value
        }
        // Check for UMLElement
        if let element = umlModel.elements?.first(where: { $0.value.boundsContains(point: point) }) {
            if element.value.type?.isElementNotSelectable == true {
                if let ownerName = element.value.owner {
                    return umlModel.elements?[ownerName]
                }
            }
            if element.value.type?.isContainer == true {
                if let containerChild = element.value.children?.first(where: { $0.boundsContains(point: point) }) {
                    return containerChild
                }
            }
            return element.value
        }

        return nil
    }

    /// Remove the selectedItem
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

    /// Update the position of an UMLElement
    func updateElementPosition(value: DragGesture.Value) {
        if let element = selectedElement as? UMLElement {
            updatePositionRecursivelyForAllChildren(element, translation: value.translation)
        }
    }

    /// Recursively check the children of each element and move them, until an element has no more children
    private func updatePositionRecursivelyForAllChildren(_ element: UMLElement, translation: CGSize) {
        element.bounds?.x += translation.width.rounded(.towardZero)
        element.bounds?.y += translation.height.rounded(.towardZero)

        if let children = element.children {
            for child in children {
                updatePositionRecursivelyForAllChildren(child, translation: translation)
            }
        }
    }

    //    func checkIfElementIsInContainer(elementToCheck: UMLElement) {
    //        if let elements = umlModel.elements {
    //            for element in elements {
    //                if let type = element.value.type, type.isContainer {
    //                    if let containerRect = element.value.boundsAsCGRect, let elementRect = elementToCheck.boundsAsCGRect {
    //                        if containerRect.contains(elementRect) {
    //                            elementToCheck.owner = element.value.id
    //                            element.value.addChild(elementToCheck)
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }

    /// Updates the Element Size after dragging the resize button
    func updateElementSize(drag: CGSize) {
        let widthToAdd = drag.width.rounded(.towardZero)
        let heightToAdd = drag.height.rounded(.towardZero)

        if let element = selectedElement as? UMLElement {
            element.bounds?.width += widthToAdd
            element.bounds?.height += heightToAdd

            if element.type?.isContainer == false {
                if let children = element.children {
                    for child in children {
                        child.bounds?.width += widthToAdd
                        child.bounds?.height += heightToAdd
                    }
                }
            }
        }
    }

    /// Adjust the diagram size based on the elements within the UMLModel
    func adjustDiagramSize() {
        let DIAGRAM_MARGIN = 40.0
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
            umlModel.size?.width = largestXBottomRight + DIAGRAM_MARGIN
            umlModel.size?.height = largestYBottomRight + DIAGRAM_MARGIN

            if smallestXTopLeft < 0.0 || smallestYTopLeft < 0.0 {
                for element in elements {
                    element.value.bounds?.x += abs(smallestXTopLeft)
                    element.value.bounds?.y += abs(smallestYTopLeft)
                }
                umlModel.size?.width += -(smallestXTopLeft) + DIAGRAM_MARGIN
                umlModel.size?.height += -(smallestYTopLeft) + DIAGRAM_MARGIN
            }
            calculateIdealScale()
        }
    }

    /// Adds an element to the UMLModel based on a UMLElementType
    func addElement(type: UMLElementType) {
        if let elementCreator = ElementCreatorFactory.createElementCreator(for: type) {
            let elementsToAdd = elementCreator.createAllElements(for: type, pointToAdd: getPointToAddElement())
            for element in elementsToAdd {
                if let elementId = element.id {
                    umlModel.elements?[elementId] = element
                    adjustDiagramSize()
                }
            }
        } else {
            log.error("Attempted to create an unknown element")
        }
    }

    /// Returns a point where the new element should be added
    func getPointToAddElement() -> CGPoint {
        guard let modelWidth = umlModel.size?.width,
              let modelHeight = umlModel.size?.height,
              modelWidth >= 1,
              modelHeight >= 1
        else {
            return CGPoint(x: 0, y: 0)
        }

        // Currently only returns a random point within the model where the new element should be added
        // TODO: Change the way the point to add is calculated
        let randomX = CGFloat.random(in: 0..<modelWidth).rounded(.towardZero)
        let randomY = CGFloat.random(in: 0..<modelHeight).rounded(.towardZero)

        return CGPoint(x: randomX, y: randomY)
    }

    /// Returns an UMLElement based on a given element ID
    func getElementById(elementId: String) -> UMLElement? {
        if let element = umlModel.elements?.first(where: { $0.key == elementId }) {
            return element.value
        }
        return nil
    }

    /// Returns the UMLElementType based on a given element ID
    func getElementTypeById(elementId: String) -> UMLElementType? {
        if let element = umlModel.elements?.first(where: { $0.key == elementId }) {
            return element.value.type ?? nil
        }
        return nil
    }
}

// MARK: Relationship path creating and editing adapted from the Apollon codebase
// https://github.com/ls1intum/Apollon
extension ApollonEditViewModel {
    /// Updates and calculates all relationship paths between 2 endpoints
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
                    let sourcePointMargin = sourcePortPoint.add(getMarginPoint(direction: sourceDirection))
                    let targetPointMargin = targetPortPoint.add(getMarginPoint(direction: targetDirection))

                    path.append(startPoint)
                    path.append(startPoint.add(getMarginPoint(direction: sourceDirection)))

                    // The delta helps determine if the path segment should be horizontal or vertical
                    let delta = Delta(dx: abs(targetPortPoint.x - sourcePortPoint.x),
                                      dy: abs(targetPortPoint.y - sourcePortPoint.y))

                    // Calculates if a horizontal or vertical path needs to be added and appends it to the path
                    // Positive stride step goes up and negative goes down
                    if delta.dx >= delta.dy {
                        // Horizontal path
                        let step = (targetPointMargin.x > sourcePointMargin.x) ? 1.0 : -1.0
                        for x in stride(from: sourcePointMargin.x, to: targetPointMargin.x + step, by: step) {
                            let y = sourcePointMargin.y // Keep y constant
                            path.append(PathPoint(x: (x - newBounds.x).rounded(.towardZero), y: (y - newBounds.y).rounded(.towardZero)))
                        }
                    } else {
                        // Vertical path
                        let step = (targetPointMargin.y > sourcePointMargin.y) ? 1.0 : -1.0
                        for y in stride(from: sourcePointMargin.y, to: targetPointMargin.y + step, by: step) {
                            let x = sourcePointMargin.x // Keep x constant
                            path.append(PathPoint(x: (x - newBounds.x).rounded(.towardZero), y: (y - newBounds.y).rounded(.towardZero)))
                        }
                    }

                    var roundedEndPointWithMargin = endPoint.add(getMarginPoint(direction: targetDirection))
                    roundedEndPointWithMargin.x = roundedEndPointWithMargin.x.rounded(.towardZero)
                    roundedEndPointWithMargin.y = roundedEndPointWithMargin.y.rounded(.towardZero)

                    path.append(roundedEndPointWithMargin)
                    path.append(endPoint)
                }
                relationship.value.path = beautifyPath(path: path)
            }
        }
    }

    /// Returns the point based on the direction of the relationship
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

    /// Returns the second point or second last point of the path which we call the margin point
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

    /// Calculates the boundary around 2 points
    private func calculateBoundaryAroundPoints(point1: PathPoint, point2: PathPoint) -> Boundary {
        return Boundary(x: min(point1.x, point2.x), y: min(point1.y, point2.y), width: abs(point2.x - point1.x), height: abs(point2.y - point1.y))
    }

    /// Makes the path nicer and removes unnecessary points
    private func beautifyPath(path: [PathPoint]) -> [PathPoint] {
        if path.count <= 1 {
            return path
        }
        var path = path
        path = removeConsecutiveIdenticalPoints(path: path)
        path = mergeConsecutiveSameAxisDeltas(path: path)
        path = flattenWaves(path: path)
        path = removeTransitNodes(path: path)

        return path;
    }

    /// Removes similar points
    private func removeConsecutiveIdenticalPoints(path: [PathPoint]) -> [PathPoint] {
        var newPath: [PathPoint] = []
        for point in path {
            let previousPoint = newPath.last
            if previousPoint == nil || !pointsAreEqual(p: point, q: previousPoint!) {
                newPath.append(point)
            }
        }
        return newPath
    }

    /// Combine deltas on the same axis
    private func mergeConsecutiveSameAxisDeltas(path: [PathPoint]) -> [PathPoint] {
        let deltas = computePathDeltas(path: path)
        if deltas.count <= 1 {
            return path
        }
        var newDeltas: [Delta] = []
        for delta in deltas {
            if newDeltas.isEmpty {
                newDeltas.append(delta)
            } else if let previousDelta = newDeltas.last {
                if (previousDelta.dx == 0 && delta.dx == 0) || (previousDelta.dy == 0 && delta.dy == 0) {
                    newDeltas[newDeltas.count - 1] = Delta(dx: previousDelta.dx + delta.dx, dy: previousDelta.dy + delta.dy)
                } else {
                    newDeltas.append(delta)
                }
            }
        }
        return createPathFromDeltas(start: path[0], deltas: newDeltas)
    }

    /// Simplifies W-shaped path segments
    private func flattenWaves(path: [PathPoint]) -> [PathPoint] {
        if path.count < 4 {
            return path
        }

        let deltas = computePathDeltas(path: path)
        let simplifiedDeltas = simplifyDeltas(deltas)

        let start = path[0]
        let simplifiedPath = createPathFromDeltas(start: start, deltas: simplifiedDeltas)

        return simplifiedPath
    }

    /// Removes transit nodes
    private func removeTransitNodes(path: [PathPoint]) -> [PathPoint] {
        for i in 0..<(path.count - 2) {
            let p = path[i]
            let q = path[i + 1]
            let r = path[i + 2]
            if isHorizontalLineSegment(p: p, q: q, r: r) || isVerticalLineSegment(p: p, q: q, r: r) {
                let pointsBeforeQ = Array(path[0...i])
                let pointsAfterQ = Array(path[(i + 2)...])
                let pathWithoutQ = pointsBeforeQ + pointsAfterQ
                return removeTransitNodes(path: pathWithoutQ)
            }
        }
        return path
    }

    /// Simplifies deltas
    private func simplifyDeltas(_ deltas: [Delta]) -> [Delta] {
        var simplifiedDeltas = deltas

        for i in 0..<(deltas.count - 3) {
            let d1 = deltas[i]
            let d2 = deltas[i + 1]
            let d3 = deltas[i + 2]
            let d4 = deltas[i + 3]

            if d1.dy == 0 && d2.dx == 0 && d3.dy == 0 &&
                (d1.dx * d3.dx > 0) && (d2.dy * d4.dy > 0) {
                simplifiedDeltas = simplifyDeltas(
                    Array(simplifiedDeltas[0..<i]) +
                    [Delta(dx: d1.dx + d3.dx, dy: 0), Delta(dx: 0, dy: d2.dy)] +
                    Array(simplifiedDeltas[(i + 3)...])
                )
                break
            }

            if d1.dx == 0 && d2.dy == 0 && d3.dx == 0 &&
                (d1.dy * d3.dy > 0) && (d2.dx * d4.dx > 0) {
                simplifiedDeltas = simplifyDeltas(
                    Array(simplifiedDeltas[0..<i]) +
                    [Delta(dx: 0, dy: d1.dy + d3.dy), Delta(dx: d2.dx, dy: 0)] +
                    Array(simplifiedDeltas[(i + 3)...])
                )
                break
            }
        }

        return simplifiedDeltas
    }

    /// Computes deltas for a given path
    private func computePathDeltas(path: [PathPoint]) -> [Delta] {
        var deltas: [Delta] = []
        for i in 0..<path.count - 1 {
            let p = path[i]
            let q = path[i + 1]
            let dx = q.x - p.x
            let dy = q.y - p.y
            deltas.append(Delta(dx: dx, dy: dy))
        }
        return deltas
    }

    /// Creates a path from a starting point and given deltas
    private func createPathFromDeltas(start: PathPoint, deltas: [Delta]) -> [PathPoint] {
        var points = [start]
        var current = start
        for delta in deltas {
            let x = current.x + delta.dx
            let y = current.y + delta.dy
            current = PathPoint(x: x, y: y)
            points.append(current)
        }
        return points
    }

    /// Checks if line segment is horizontal
    private func isHorizontalLineSegment(p: PathPoint, q: PathPoint, r: PathPoint) -> Bool {
        return areAlmostEqual(a: p.y, b: q.y) && areAlmostEqual(a: q.y, b: r.y) && ((p.x >= q.x && q.x >= r.x) || (p.x <= q.x && q.x <= r.x))
    }

    /// Checks if line segment is vertical
    private func isVerticalLineSegment(p: PathPoint, q: PathPoint, r: PathPoint) -> Bool {
        return areAlmostEqual(a: p.x, b: q.x) && areAlmostEqual(a: q.x, b: r.x) && ((p.y <= q.y && q.y <= r.y) || (p.y >= q.y && q.y >= r.y))
    }

    /// Checks if value is almost zero
    private func isAlmostZero(value: Double) -> Bool {
        return abs(value) < 1e-6
    }

    /// Checks if 2 doubles are almost equal
    private func areAlmostEqual(a: Double, b: Double) -> Bool {
        return isAlmostZero(value: a - b)
    }

    /// Checks if 2 points are equal
    private func pointsAreEqual(p: PathPoint, q: PathPoint) -> Bool {
        let dx = abs(p.x - q.x)
        let dy = abs(p.y - q.y)
        return isAlmostZero(value: dx) && isAlmostZero(value: dy)
    }

    private struct Delta {
        var dx: Double
        var dy: Double
    }
}
