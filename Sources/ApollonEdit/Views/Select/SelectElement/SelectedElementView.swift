import SwiftUI
import ApollonShared

struct SelectedElementView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @Binding var elementMoveStarted: Bool
    @Binding var elementResizeStarted: Bool
    
    @State var isShowingRelationshipConnectionPoints: Bool = false
    @State private var isDrawingLine = false
    @State var isConnectionSelected: Bool = false
    @State var source = UMLRelationshipEndPoint()
    @State var target = UMLRelationshipEndPoint()
    
    // For the drawing path when creating relationship connections
    @State private var startPoint: CGPoint = .zero
    @State private var endPoint: CGPoint = .zero
    
    @State var elementResizeBounds: CGSize = .zero
    
    var body: some View {
        if let bounds = viewModel.selectedElementBounds {
            ZStack {
                //SELECTED ITEM
                Rectangle()
                    .stroke(viewModel.themeColor, lineWidth: 5)
                    .opacity(0.5)
                    .frame(width: bounds.width, height: bounds.height)
                    .position(x: bounds.x + (bounds.width / 2), y: bounds.y + (bounds.height / 2))
                
                // UP
                RelationshipConnectionPoint(color: viewModel.themeColor, trimFrom: 0.5, trimTo: 1, x: bounds.x + (bounds.width / 2), y: bounds.y)
                    .opacity(elementMoveStarted || elementResizeStarted ? 0 : 0.5)
                    .gesture(
                        DragGesture()
                            .onChanged() { gesture in
                                handleRelationshipDraw(gesture, startPointX: bounds.x + (bounds.width / 2), startPointY: bounds.y)
                            }
                            .onEnded() { gesture in
                                handleRelationshipDrawEnded(gesture, sourceDirection: .up)
                            }
                    )
                
                // DOWN
                RelationshipConnectionPoint(color: viewModel.themeColor, trimFrom: 0, trimTo: 0.5, x: bounds.x + (bounds.width / 2), y: bounds.y + bounds.height)
                    .opacity(elementMoveStarted || elementResizeStarted ? 0 : 0.5)
                    .gesture(
                        DragGesture()
                            .onChanged() { gesture in
                                handleRelationshipDraw(gesture, startPointX: bounds.x + (bounds.width / 2), startPointY: bounds.y + bounds.height)
                            }
                            .onEnded() { gesture in
                                handleRelationshipDrawEnded(gesture, sourceDirection: .down)
                            }
                    )
                
                // LEFT
                RelationshipConnectionPoint(color: viewModel.themeColor, trimFrom: 0.25, trimTo: 0.75, x: bounds.x, y: bounds.y + (bounds.height / 2))
                    .opacity(elementMoveStarted || elementResizeStarted ? 0 : 0.5)
                    .gesture(
                        DragGesture()
                            .onChanged() { gesture in
                                handleRelationshipDraw(gesture, startPointX: bounds.x, startPointY: bounds.y + (bounds.height / 2))
                            }
                            .onEnded() { gesture in
                                handleRelationshipDrawEnded(gesture, sourceDirection: .left)
                            }
                    )
                
                // RIGHT
                RelationshipConnectionPoint(color: viewModel.themeColor, trimFrom: 0.5, trimTo: 1, rotation: 90, x: bounds.x + bounds.width, y: bounds.y + (bounds.height / 2))
                    .opacity(elementMoveStarted || elementResizeStarted ? 0 : 0.5)
                    .gesture(
                        DragGesture()
                            .onChanged() { gesture in
                                handleRelationshipDraw(gesture, startPointX: bounds.x + bounds.width, startPointY: bounds.y + (bounds.height / 2))
                            }
                            .onEnded() { gesture in
                                handleRelationshipDrawEnded(gesture, sourceDirection: .right)
                            }
                    )
                
                // Shows the connection points and drawing line when the selected element connection point is hovered
                if isShowingRelationshipConnectionPoints {
                    DrawingLineView(isDrawing: $isDrawingLine, startPoint: $startPoint, endPoint: $endPoint)
                    if let elements = viewModel.umlModel.elements {
                        ForEach(Array(elements), id: \.key) { key, element in
                            if key != viewModel.selectedElement?.id {
                                if element.type?.isElementNotSelectable != true {
                                    RelationshipConnectionPoints(element: element,
                                                                 color: viewModel.themeColor,
                                                                 target: $target,
                                                                 endPoint: $endPoint,
                                                                 isConnectionSelected: $isConnectionSelected)
                                }
                            }
                        }
                    }
                }
                
                // The button for the moving of the selected element
                if !elementResizeStarted {
                    MoveSelectedItemButton(viewModel: viewModel)
                        .position(CGPoint(x: bounds.x - 25, y: bounds.y + (bounds.height + 25)))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    elementMoveStarted = true
                                    viewModel.selectedElementBounds?.x = value.location.x + 25
                                    viewModel.selectedElementBounds?.y = value.location.y - (bounds.height + 25)
                                }
                                .onEnded { value in
                                    //viewModel.updateElementPosition(location: CGPoint(x: value.location.x + 25, y: value.location.y - (bounds.height + 25)))
                                    viewModel.updateElementPosition(value: value)
                                    viewModel.adjustDiagramSize()
                                    viewModel.updateRelationshipPosition()
                                    elementMoveStarted = false
                                    viewModel.selectedElement = nil
                                }
                        )
                }
                
                // The button for the resizing of the selected element
                if !elementMoveStarted {
                    if let resizeBy = (viewModel.selectedElement as? UMLElement)?.type?.resizeBy {
                        ResizeSelectedItemButton(viewModel: viewModel, resizeBy: resizeBy)
                            .position(CGPoint(x: bounds.x + (bounds.width + 25), y: bounds.y + (bounds.height + 25)))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        handleElementResize(value, resizeBy: resizeBy)
                                    }
                                    .onEnded { value in
                                        viewModel.updateElementSize(drag: elementResizeBounds)
                                        viewModel.adjustDiagramSize()
                                        viewModel.updateRelationshipPosition()
                                        elementResizeStarted = false
                                        viewModel.selectedElement = nil
                                    }
                            )
                    }
                }
                
                // The button for the editing of the selected element
                if !elementMoveStarted && !elementResizeStarted {
                    EditSelectedItemButton(viewModel: viewModel)
                        .position(CGPoint(x: bounds.x + (bounds.width / 2), y: bounds.y - 50))
                }
            }.onChange(of: isConnectionSelected) {
                // Adds a new relationship to the model, if a connection point was found
                let relationship = UMLRelationship(type: viewModel.diagramType.diagramRelationshipTypes.first, source: self.source, target: self.target)
                viewModel.umlModel.relationships?[relationship.id ?? ""] = relationship
                viewModel.updateRelationshipPosition()
                isConnectionSelected = false
                viewModel.selectedElement = nil
            }
        }
    }
    
    private func handleRelationshipDraw(_ gesture: DragGesture.Value, startPointX: CGFloat, startPointY: CGFloat) {
        isShowingRelationshipConnectionPoints = true
        startPoint = CGPoint(x: startPointX, y: startPointY)
        endPoint = gesture.location
        isDrawingLine = true
    }
    
    private func handleRelationshipDrawEnded(_ gesture: DragGesture.Value, sourceDirection: Direction) {
        source.element = viewModel.selectedElement?.id
        source.direction = sourceDirection
        endPoint = gesture.location
        isDrawingLine = false
        isShowingRelationshipConnectionPoints = false
    }
    
    private func handleElementResize(_ gesture: DragGesture.Value, resizeBy: ResizeableDirection) {
        elementResizeStarted = true
        switch resizeBy {
        case .widthAndHeight:
            elementResizeBounds.width = gesture.translation.width
            elementResizeBounds.height = gesture.translation.height
        case .width:
            elementResizeBounds.width = gesture.translation.width
        case .height:
            elementResizeBounds.height = gesture.translation.height
        default:
            return
        }
        viewModel.selectedElementBounds?.width = (viewModel.selectedElement?.bounds?.width ?? 0) + elementResizeBounds.width
        viewModel.selectedElementBounds?.height = (viewModel.selectedElement?.bounds?.height ?? 0) + elementResizeBounds.height
    }
}

// The connection point, where relationships can be connected to and from
struct RelationshipConnectionPoint: View {
    let color: Color
    let trimFrom: Double
    let trimTo: Double
    var rotation: Double = 0.0
    let x: Double
    let y: Double
    
    var body: some View {
        Circle()
            .trim(from: trimFrom, to: trimTo)
            .rotation(.degrees(rotation))
            .fill(color)
            .frame(width: 50, height: 50)
            .position(x: x, y: y)
    }
}

// A struct that holds all connection points of all elements that can be connected to
struct RelationshipConnectionPoints: View {
    let element: UMLElement
    let color: Color
    @Binding var target: UMLRelationshipEndPoint
    @Binding var endPoint: CGPoint
    @Binding var isConnectionSelected: Bool
    
    var body: some View {
        if let bounds = element.bounds {
            // UP
            RelationshipConnectionPoint(color: color, trimFrom: 0.5, trimTo: 1, x: bounds.x + (bounds.width / 2), y: bounds.y)
                .opacity(0.5)
                .onDisappear() {
                    handleOnDisappear(connectionPointX: bounds.x + (bounds.width / 2) - 25, connectionPointY: bounds.y - 25, direction: .up)
                }
            
            // DOWN
            RelationshipConnectionPoint(color: color, trimFrom: 0, trimTo: 0.5, x: bounds.x + (bounds.width / 2), y: bounds.y + bounds.height)
                .opacity(0.5)
                .onDisappear() {
                    handleOnDisappear(connectionPointX: bounds.x + (bounds.width / 2) - 25, connectionPointY: bounds.y + bounds.height - 25, direction: .down)
                }
            
            // LEFT
            RelationshipConnectionPoint(color: color, trimFrom: 0.25, trimTo: 0.75, x: bounds.x, y: bounds.y + (bounds.height / 2))
                .opacity(0.5)
                .onDisappear() {
                    handleOnDisappear(connectionPointX: bounds.x - 25, connectionPointY: bounds.y + (bounds.height / 2) - 25, direction: .left)
                }
            
            // RIGHT
            RelationshipConnectionPoint(color: color, trimFrom: 0.5, trimTo: 1, rotation: 90, x: bounds.x + bounds.width, y: bounds.y + (bounds.height / 2))
                .opacity(0.5)
                .onDisappear() {
                    handleOnDisappear(connectionPointX: bounds.x + bounds.width - 25, connectionPointY: bounds.y + (bounds.height / 2) - 25, direction: .right)
                }
        }
    }
    
    // This function checks if the endPoint of the new realtionship path is within the bounding box of a connection point of the element and adds it as the target
    private func handleOnDisappear(connectionPointX: CGFloat, connectionPointY: CGFloat, direction: Direction) {
        let rect = CGRect(x: connectionPointX, y: connectionPointY, width: 50, height: 50)
        if rect.contains(endPoint) {
            target.element = element.id ?? ""
            target.direction = direction
            isConnectionSelected = true
        }
    }
}

// The line that is rendered, when the drawing of a new relationship is initiated
struct DrawingLineView: View {
    @Binding var isDrawing: Bool
    @Binding var startPoint: CGPoint
    @Binding var endPoint: CGPoint
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                if isDrawing {
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
