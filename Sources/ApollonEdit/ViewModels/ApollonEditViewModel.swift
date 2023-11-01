import Foundation
import SwiftUI
import ApollonRenderer
import ApollonShared

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
    @Published var currentDiagramSize: CGSize = .zero
    
    @MainActor
    var diagramSize: CGSize {
        umlModel?.size?.asCGSize ?? CGSize()
    }
    
    @MainActor
    func setDragLocation(at point: CGPoint? = nil) {
        if let point {
            currentDragLocation = point
        } else {
            currentDragLocation = CGPoint(x: geometrySize.width / 2, y: geometrySize.height / 2)
        }
    }
    
    @MainActor
    func setupScale(geometrySize: CGSize) {
        self.geometrySize = geometrySize
        self.currentDiagramSize = umlModel?.size?.asCGSize ?? CGSize()
        calculateIdealScale()
        scale = idealScale
    }
    
    @MainActor
    func calculateIdealScale() {
        let scaleWidth = self.geometrySize.width / max(diagramSize.width, currentDiagramSize.width)
        let scaleHeight = self.geometrySize.height / max(diagramSize.height, currentDiagramSize.height)
        let initialScale = min(scaleWidth, scaleHeight)
        idealScale = min(max(initialScale, minScale), maxScale) - 0.05
    }
    
    @MainActor
    func adjustDiagramSizeForSelectedElement() {
        var largestXBottomRight: CGFloat = 0.0
        var largestYBottomRight: CGFloat = 0.0
        var smallestXTopLeft: CGFloat = 0.0
        var smallestYTopLeft: CGFloat = 0.0
        if let elements = umlModel?.elements {
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
            currentDiagramSize.width = largestXBottomRight
            currentDiagramSize.height = largestYBottomRight
            
            if smallestXTopLeft < 0.0 || smallestYTopLeft < 0.0 {
                for elementOrigin in elements {
                    elementOrigin.value.bounds?.x += -(smallestXTopLeft)
                    elementOrigin.value.bounds?.y += -(smallestYTopLeft)
                }
                currentDiagramSize.width += -(smallestXTopLeft)
                currentDiagramSize.height += -(smallestYTopLeft)
            }
        }
    }
    
    @MainActor
    func selectItem(at point: CGPoint) {
        self.selectedElement = getSelectableItem(at: point)
        self.selectedElementBounds = self.selectedElement?.bounds
    }
    
    @MainActor
    private func getSelectableItem(at point: CGPoint) -> SelectableUMLItem? {
        /// Check for UMLRelationship
        if let relationship = umlModel?.relationships?.first(where: { $0.value.boundsContains(point: point) }) {
            return relationship.value
        }
        /// Check for UMLElement
        if let elements = umlModel?.elements {
            for element in elements where element.value.boundsContains(point: point) {
                if element.value.type?.isElementNotSelectable == true {
                    if let ownerName = element.value.owner {
                        return umlModel?.elements?[ownerName]
                    }
                } else {
                    return element.value
                }
            }
        }
        return nil
    }
    
    @MainActor
    func removeSelectedItem() {
        if let elements = umlModel?.elements {
            for element in elements {
                if element.value.owner == selectedElement?.id {
                    umlModel?.elements?.removeValue(forKey: element.key)
                }
            }
            
        }
        umlModel?.elements?.removeValue(forKey: selectedElement?.id ?? "")
        if let relationships = umlModel?.relationships {
            for relationship in relationships {
                if relationship.value.source?.element == selectedElement?.id || relationship.value.target?.element == selectedElement?.id {
                    umlModel?.relationships?.removeValue(forKey: relationship.key)
                }
            }
        }
        umlModel?.relationships?.removeValue(forKey: selectedElement?.id ?? "")
        selectedElement = nil
    }
    
    @MainActor
    func updateElementPosition(location: CGPoint) {
        if let element = selectedElement as? UMLElement {
            selectedElement?.bounds?.x = location.x
            selectedElement?.bounds?.y = location.y
            
            //            if let relationships = umlModel?.relationships {
            //                for (index, relationship) in relationships.enumerated() {
            //                    if var bounds = relationship.bounds {
            //                        // SOURCE ELEMENT
            //                        if relationship.source?.element == element.id {
            //                            if var path = relationship.path {
            //                            }
            //                            // TARGET ELEMENT
            //                        } else if relationship.target?.element == element.id {
            //                            if var path = relationship.path {
            //                            }
            //                        }
            //                        let newWidth = bounds.width + (bounds.x - location.x)
            //                        let newHeight = bounds.height + (bounds.y - location.y)
            //                        bounds.width = newWidth
            //                        bounds.height = newHeight
            //                        umlModel?.relationships?[index].bounds = bounds
            //                    }
            //                }
            //            }
            
            if var offset = element.bounds?.height, let elements = umlModel?.elements, let children = element.verticallySortedChildren {
                for child in children.reversed() {
                    for childElement in elements where child.id == childElement.key {
                        if let childBounds = childElement.value.bounds {
                            offset -= childBounds.height
                            umlModel?.elements?[childElement.key]?.bounds?.x = location.x
                            umlModel?.elements?[childElement.key]?.bounds?.y = location.y + offset
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    func updateElementSize(drag: CGSize) {
        if let element = selectedElement as? UMLElement {
            selectedElement?.bounds?.width += drag.width
            if let children = element.verticallySortedChildren {
                for child in children {
                    child.bounds?.width += drag.width
                }
            }
        }
    }
    
    @MainActor
    func addElement(type: UMLElementType) {
        let middle = CGPoint(x: diagramSize.width / 2, y: diagramSize.height / 2)
        let elementCreator = ElementCreatorFactory.createElementCreator(for: type)
        if let elementCreator {
            let elementsToAdd = elementCreator.createAllElements(for: type, middle: middle)
            for element in elementsToAdd {
                if let elementId = element.id {
                    umlModel?.elements?[elementId] = element
                }
            }
        } else {
            log.error("Attempted to create an unknown element")
        }
        determineChildren()
    }
    
    func getElementById(elementId: String) -> UMLElement? {
        if let element = umlModel?.elements?.first(where: { $0.key == elementId }) {
            return element.value
        }
        return nil
    }
    
    func getElementTypeById(elementId: String) -> UMLElementType? {
        if let element = umlModel?.elements?.first(where: { $0.key == elementId }) {
            return element.value.type ?? nil
        }
        return nil
    }
}
