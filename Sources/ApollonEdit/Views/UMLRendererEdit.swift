import SwiftUI
import ApollonShared

struct UMLRendererEdit: View {
    @StateObject var viewModel: ApollonEditViewModel
    @State private var startDragLocation = CGPoint.zero
    @State private var dragStarted = true
    @State private var elementDragStarted = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Group {
                if viewModel.isGridBackground {
                    GridBackgroundView()
                }
                Canvas(rendersAsynchronously: true) { context, size in
                    viewModel.render(&context, size: size)
                }
                .onTapGesture { tapLocation in
                    viewModel.selectItem(at: tapLocation)
                }
                if viewModel.selectedElement != nil {
                    if viewModel.selectedElement is UMLElement {
                        SelectedElementView(viewModel: viewModel, elementDragStarted: $elementDragStarted)
                    } else if viewModel.selectedElement is UMLRelationship {
                        SelectedRelationshipView(viewModel: viewModel)
                    }
                }
            }.frame(minWidth: viewModel.diagramSize.width, minHeight: viewModel.diagramSize.height)
                .padding()
                .scaleEffect(viewModel.scale * viewModel.progressingScale)
                .position(viewModel.currentDragLocation)
        }.onChange(of: viewModel.diagramSize) { _ in
            viewModel.setDragLocation()
        }.gesture(
            !elementDragStarted ?
            DragGesture()
                .onChanged(handleDrag)
                .onEnded { _ in
                    dragStarted = true
                }
            : nil
        ).simultaneousGesture(
            !elementDragStarted ?
            MagnificationGesture()
                .onChanged(handleMagnification)
                .onEnded(handleMagnificationEnd)
            : nil
        )
    }
    
    private func handleDrag(_ gesture: DragGesture.Value) {
        if dragStarted {
            dragStarted = false
            startDragLocation = viewModel.currentDragLocation
        }
        viewModel.setDragLocation(at: CGPoint(x: startDragLocation.x + gesture.translation.width,
                                              y: startDragLocation.y + gesture.translation.height))
    }
    
    private func handleMagnification(_ newScale: MagnificationGesture.Value) {
        viewModel.progressingScale = newScale
        
        // Enforce zoom out limit
        if viewModel.progressingScale * viewModel.scale < viewModel.minScale {
            viewModel.progressingScale = viewModel.minScale / viewModel.scale
        }
        // Enforce zoom in limit
        if viewModel.progressingScale * viewModel.scale > viewModel.maxScale {
            viewModel.progressingScale = viewModel.maxScale / viewModel.scale
        }
    }
    
    private func handleMagnificationEnd(_ finalScale: MagnificationGesture.Value) {
        viewModel.scale *= finalScale
        viewModel.progressingScale = 1
        
        // Enforce zoom out limit
        if viewModel.scale < viewModel.minScale {
            viewModel.scale = viewModel.minScale
        }
        // Enforce zoom in limit
        if viewModel.scale > viewModel.maxScale {
            viewModel.scale = viewModel.maxScale
        }
    }
}
