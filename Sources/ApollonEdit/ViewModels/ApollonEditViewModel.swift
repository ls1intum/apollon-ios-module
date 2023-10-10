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
    @Published var minScale: CGFloat = 0.3
    @Published var maxScale: CGFloat = 5.0
    
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
    
    private func getSelectableItem(at point: CGPoint) -> SelectableUMLItem? {
        /// Check for UMLRelationship
        if let relationship = umlModel?.relationships?.first(where: { $0.boundsContains(point: point) }) {
            return relationship
        }
        /// Check for UMLElement
        if let elements = umlModel?.elements {
            for element in elements where element.boundsContains(point: point) {
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
    func renderHighlights(_ context: inout GraphicsContext, size: CGSize) {
        if let element = selectedElement {
            if let bounds = element.bounds {
                let highlightRect = CGRect(x: bounds.x, y: bounds.y, width: bounds.width, height: bounds.height)
                if element is UMLRelationship {
                    context.fill(Path(highlightRect), with: .color(Color.blue.opacity(0.5)))
                } else if element is UMLElement{
                    context.stroke(Path(highlightRect), with: .color(Color.blue.opacity(0.5)), lineWidth: 5)
                    context.fill(halfCircleHighlight(bounds: bounds, direction: .left), with: .color(Color.blue.opacity(0.5)))
                    context.fill(halfCircleHighlight(bounds: bounds, direction: .right), with: .color(Color.blue.opacity(0.5)))
                    context.fill(halfCircleHighlight(bounds: bounds, direction: .up), with: .color(Color.blue.opacity(0.5)))
                    context.fill(halfCircleHighlight(bounds: bounds, direction: .down), with: .color(Color.blue.opacity(0.5)))
                }
            }
        }
    }
    
    private func halfCircleHighlight(bounds: Boundary, direction: Direction) -> Path {
        var x, y, startAngle, endAngle: Double
        switch direction {
        case .left:
            startAngle = 270
            endAngle = 90
            x = bounds.x
            y = bounds.y + bounds.height / 2
        case .right:
            startAngle = 90
            endAngle = 270
            x = bounds.x + bounds.width
            y = bounds.y + bounds.height / 2
        case .up:
            startAngle = 0
            endAngle = 180
            x = bounds.x + bounds.width / 2
            y = bounds.y
        case .down:
            startAngle = 180
            endAngle = 0
            x = bounds.x + bounds.width / 2
            y = bounds.y + bounds.height
        default:
            return Path()
        }
        return Path { path in
            path.addArc(center: CGPoint(x: x, y: y),
                        radius: 20,
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(endAngle),
                        clockwise: true)
        }
    }
    
    @MainActor
    func updateElementPosition(location: CGPoint, drag: DragGesture.Value) {
        if let element = selectedElement as? UMLElement {
            selectedElement?.bounds?.x = location.x
            selectedElement?.bounds?.y = location.y
            
            //            if let relationships = diagram?.model?.relationships {
            //                for (index, relationship) in relationships.enumerated() {
            //                    if var bounds = relationship.bounds {
            //                        if relationship.source?.element == element.id {
            ////                            if var path = relationship.path {
            ////                                if path.count >= 2 {
            ////                                    var pathFirst = path.first
            ////                                    var pathLast = path.last
            ////                                }
            ////                                for (pathIndex, _) in path.enumerated() where pathIndex > 0{
            ////                                    path[pathIndex].x += drag.translation.width
            ////                                    path[pathIndex].y += drag.translation.height
            ////                                }
            ////                                diagram?.model?.relationships?[index].path = path
            ////                            }
            //                            //bounds.x = location.x
            //                            //bounds.y = location.y
            ////                            bounds.width = drag.translation.width
            ////                            bounds.height = drag.translation.height
            //                            diagram?.model?.relationships?[index].bounds = bounds
            //                        } else if relationship.target?.element == element.id {
            //                            if var path = relationship.path {
            //                                path.last.x =
            //                                path.last.y =
            //                                for (pathIndex, _) in path.enumerated() where pathIndex > 0 {
            //                                    path[pathIndex].x += drag.translation.width
            //                                    path[pathIndex].y += drag.translation.height
            //                                }
            //                                diagram?.model?.relationships?[index].path = path
            //                            }
            ////                            let newWidth = bounds.width + (bounds.x - location.x)
            ////                            let newHeight = bounds.height + (bounds.y - location.y)
            ////                            bounds.width = newWidth
            ////                            bounds.height = newHeight
            //                            diagram?.model?.relationships?[index].bounds = bounds
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
            //log.warning("Could not find elements in the model")
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
        if let width = umlModel?.size?.width {
            if let height = umlModel?.size?.height {
                let middleWidth = width / 2
                let middleHeight = height / 2
                let elementID = UUID().uuidString
                
                switch type {
                case .package:
                    let element = UMLElement(id: elementID, name: type.rawValue, type: type, owner: nil, bounds: Boundary(x: middleWidth, y: middleHeight, width: 200, height: 100), assessmentNote: nil)
                    umlModel?.elements?.append(element)
                case .Class:
                    let element = UMLElement(id: elementID, name: type.rawValue, type: type, owner: nil, bounds: Boundary(x: middleWidth, y: middleHeight, width: 200, height: 120), assessmentNote: nil)
                    let elementAttribute = UMLElement(id: UUID().uuidString, name: "+ attribute: Type", type: UMLElementType.classAttribute, owner: elementID, bounds: Boundary(x: middleWidth, y: middleHeight + 40, width: 200, height: 40), assessmentNote: nil)
                    let elementMethod = UMLElement(id: UUID().uuidString, name: "+ method()", type: UMLElementType.classMethod, owner: elementID, bounds: Boundary(x: middleWidth, y: middleHeight + 80, width: 200, height: 40), assessmentNote: nil)
                    umlModel?.elements?.append(element)
                    umlModel?.elements?.append(elementAttribute)
                    umlModel?.elements?.append(elementMethod)
                case .abstractClass, .interface:
                    let element = UMLElement(id: elementID, name: type.rawValue, type: type, owner: nil, bounds: Boundary(x: middleWidth, y: middleHeight, width: 200, height: 130), assessmentNote: nil)
                    let elementAttribute = UMLElement(id: UUID().uuidString, name: "+ attribute: Type", type: UMLElementType.classAttribute, owner: elementID, bounds: Boundary(x: middleWidth, y: middleHeight + 50, width: 200, height: 40), assessmentNote: nil)
                    let elementMethod = UMLElement(id: UUID().uuidString, name: "+ method()", type: UMLElementType.classMethod, owner: elementID, bounds: Boundary(x: middleWidth, y: middleHeight + 90, width: 200, height: 40), assessmentNote: nil)
                    umlModel?.elements?.append(element)
                    umlModel?.elements?.append(elementAttribute)
                    umlModel?.elements?.append(elementMethod)
                case .enumeration:
                    let element = UMLElement(id: elementID, name: type.rawValue, type: type, owner: nil, bounds: Boundary(x: middleWidth, y: middleHeight, width: 200, height: 170), assessmentNote: nil)
                    let elementAttribute1 = UMLElement(id: UUID().uuidString, name: "Case 1", type: UMLElementType.classAttribute, owner: elementID, bounds: Boundary(x: middleWidth, y: middleHeight + 50, width: 200, height: 40), assessmentNote: nil)
                    let elementAttribute2 = UMLElement(id: UUID().uuidString, name: "Case 2", type: UMLElementType.classAttribute, owner: elementID, bounds: Boundary(x: middleWidth, y: middleHeight + 90, width: 200, height: 40), assessmentNote: nil)
                    let elementAttribute3 = UMLElement(id: UUID().uuidString, name: "Case 3", type: UMLElementType.classAttribute, owner: elementID, bounds: Boundary(x: middleWidth, y: middleHeight + 130, width: 200, height: 40), assessmentNote: nil)
                    umlModel?.elements?.append(element)
                    umlModel?.elements?.append(elementAttribute1)
                    umlModel?.elements?.append(elementAttribute2)
                    umlModel?.elements?.append(elementAttribute3)
                default:
                    return
                }
            }
        }
        determineChildren()
    }
}
