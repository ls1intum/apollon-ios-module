import Foundation
import SwiftUI
import ApollonRenderer
import ApollonShared

open class ApollonEditViewModel: ApollonViewModel {
    @Published var selectedElement: SelectableUMLItem?
    @Published var geometrySize = CGSize.zero
    @Published var currentDragLocation = CGPoint.zero
    @Published var scale: CGFloat = 1.0
    @Published var progressingScale: CGFloat = 1.0
    @Published var minScale: CGFloat = 0.1
    @Published var maxScale: CGFloat = 4.0
    @Published var selectedElementBounds: Boundary?
    @Published var moveSelectedItemButtonPosition: CGPoint?
    
    @MainActor
    var diagramSize: CGSize {
        umlModel?.size?.asCGSize ?? CGSize()
    }
    
    @MainActor
    var editSelectedItemButtonPosition: CGPoint {
        if let bounds = selectedElementBounds {
            return CGPoint(x: bounds.x + (bounds.width / 2), y: bounds.y - 50)
        }
        return CGPoint(x: 0, y: 0)
    }
    
    @MainActor
    func moveSelectedItemButton(position: CGPoint? = nil) {
        if let bounds = selectedElementBounds {
            if let position {
                moveSelectedItemButtonPosition = position
            } else {
                moveSelectedItemButtonPosition = CGPoint(x: bounds.x - 25, y: bounds.y + (bounds.height + 25))
            }
        }
    }
    
    @MainActor
    var resizeSelectedItemButtonPosition: CGPoint {
        if let bounds = selectedElementBounds {
            return CGPoint(x: bounds.x + (bounds.width + 25), y: bounds.y + (bounds.height + 25))
        }
        return CGPoint(x: 0, y: 0)
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
        
        let scaleWidth = self.geometrySize.width / (diagramSize.width)
        let scaleHeight = self.geometrySize.height / (diagramSize.height)
        let initialScale = min(scaleWidth, scaleHeight)
        
        minScale = min(max(initialScale, minScale), maxScale)
        scale = minScale
    }
    
    @MainActor
    func selectItem(at point: CGPoint) {
        selectedElement = getSelectableItem(at: point)
    }
    
    @MainActor
    private func getSelectableItem(at point: CGPoint) -> SelectableUMLItem? {
        /// Check for UMLRelationship
        if let relationship = umlModel?.relationships?.first(where: { $0.boundsContains(point: point) }) {
            self.selectedElementBounds = relationship.bounds
            return relationship
        }
        /// Check for UMLElement
        if let elements = umlModel?.elements {
            for element in elements where element.boundsContains(point: point) {
                self.selectedElementBounds = element.bounds
                self.moveSelectedItemButton()
                return element
            }
        }
        return nil
    }
    
    @MainActor
    func removeSelectedItem() {
        umlModel?.elements?.removeAll { $0.owner ?? "" == self.selectedElement?.id ?? ""}
        umlModel?.elements?.removeAll { $0.id ?? "" == self.selectedElement?.id ?? ""}
        umlModel?.relationships?.removeAll {$0.source?.element ?? "" == self.selectedElement?.id ?? ""}
        umlModel?.relationships?.removeAll {$0.target?.element ?? "" == self.selectedElement?.id ?? ""}
        self.selectedElement = nil
    }
    
    @MainActor
    func updateElementPosition(location: CGPoint) {
        if let element = selectedElement as? UMLElement {
            selectedElement?.bounds?.x = location.x
            selectedElement?.bounds?.y = location.y
            
//            if let relationships = umlModel?.relationships {
//                for (index, relationship) in relationships.enumerated() {
//                    if var bounds = relationship.bounds {
//                        if relationship.source?.element == element.id {
//                            if var path = relationship.path {
//                                var pathFirst = path.first
//                                var pathLast = path.last
//                                
//                                for (pathIndex, _) in path.enumerated() where pathIndex > 0{
//                                    path[pathIndex].x += drag.translation.width
//                                    path[pathIndex].y += drag.translation.height
//                                }
//                                umlModel?.relationships?[index].path = path
//                            }
//                            bounds.x = location.x
//                            bounds.y = location.y
//                            bounds.width = drag.translation.width
//                            bounds.height = drag.translation.height
//                            umlModel?.relationships?[index].bounds = bounds
//                        } else if relationship.target?.element == element.id {
//                            if var path = relationship.path {
//                                var pathFirst = path.first
//                                var pathLast = path.last
//                                for (pathIndex, _) in path.enumerated() where pathIndex > 0 {
//                                    path[pathIndex].x += drag.translation.width
//                                    path[pathIndex].y += drag.translation.height
//                                }
//                                umlModel?.relationships?[index].path = path
//                            }
//                            let newWidth = bounds.width + (bounds.x - location.x)
//                            let newHeight = bounds.height + (bounds.y - location.y)
//                            bounds.width = newWidth
//                            bounds.height = newHeight
//                            umlModel?.relationships?[index].bounds = bounds
//                        }
//                    }
//                }
//            }
            
            if var offset = element.bounds?.height, let elements = umlModel?.elements, let children = element.verticallySortedChildren {
                for child in children.reversed() {
                    for (index, childElement) in elements.enumerated() where child.id == childElement.id {
                        if let childBounds = childElement.bounds {
                            offset -= childBounds.height
                            umlModel?.elements?[index].bounds?.x = location.x
                            umlModel?.elements?[index].bounds?.y = location.y + offset
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    func addAttributeOrMethod(name: String, type: UMLElementType) {
        guard let elements = umlModel?.elements, let children = (self.selectedElement as? UMLElement)?.verticallySortedChildren else {
            log.warning("Could not find elements in the model")
            return
        }
        var newBounds: Boundary?
        
        
        if children.isEmpty {
            if let lastBounds = self.selectedElement?.bounds {
                newBounds = Boundary(x: lastBounds.x, y: lastBounds.y + lastBounds.height, width: lastBounds.width, height: 40)
            }
        }
        
        let containsAttributes: Bool = children.contains(where: { $0.type == .classAttribute })
        let containsMethods: Bool = children.contains(where: { $0.type == .classMethod })
        
        if type == .classAttribute && !children.isEmpty {
            if !containsAttributes && containsMethods {
                if let lastBounds = children.first(where: { $0.type == .classMethod })?.bounds {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y, width: lastBounds.width, height: lastBounds.height)
                }
            } else {
                if let lastBounds = children.last(where: { $0.type == .classAttribute })?.bounds {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y + lastBounds.height, width: lastBounds.width, height: lastBounds.height)
                }
            }
        }
        
        if type == .classMethod && !children.isEmpty {
            if !containsMethods && containsAttributes {
                if let lastBounds = children.last(where: { $0.type == .classAttribute })?.bounds {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y + lastBounds.height, width: lastBounds.width, height: lastBounds.height)
                }
            } else {
                if let lastBounds = children.last(where: { $0.type == .classMethod })?.bounds {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y + lastBounds.height, width: lastBounds.width, height: lastBounds.height)
                }
            }
        }
        
        let newChild = UMLElement(id: UUID().uuidString, name: name, type: type, owner: self.selectedElement?.id, bounds: newBounds, assessmentNote: nil)
        let newItemHeight = (self.selectedElement?.bounds?.height ?? 0) + (newChild.bounds?.height ?? 0)
        selectedElement?.bounds?.height = newItemHeight
        (self.selectedElement as? UMLElement)?.addChild(newChild)
        umlModel?.elements?.append(newChild)
        
        if type == .classAttribute && containsMethods {
            if let firstMethodIndex = children.firstIndex(where: { $0.type == .classMethod }) {
                for (index, child) in children.enumerated() where index >= firstMethodIndex {
                    for (indexElement, childElement) in elements.enumerated() where child.id == childElement.id {
                        let newYForElement = (umlModel?.elements?[indexElement].bounds?.y ?? 0) + (newBounds?.height ?? 0)
                        umlModel?.elements?[indexElement].bounds?.y = newYForElement
                    }
                }
            }
        }
    }
    
    @MainActor
    func addElement(type: UMLElementType) {
        let middle = CGPoint(x: diagramSize.width / 2, y: diagramSize.height / 2)
        let elementCreator = ElementCreatorFactory.createElementCreator(for: type)
        if let elementCreator {
            umlModel?.elements?.append(contentsOf: elementCreator.createAllElements(for: type, middle: middle))
        } else {
            log.error("Attempted to create an unknown element")
        }
        determineChildren()
    }
}
