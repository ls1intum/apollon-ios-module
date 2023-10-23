import SwiftUI
import ApollonShared

struct UMLRendererEdit: View {
    @StateObject var viewModel: ApollonEditViewModel
    @StateObject var gridBackgroundViewModel = GridBackgroundViewModel()
    @State private var startDragLocation = CGPoint.zero
    @State private var dragStarted = true
    @State private var elementMoveStarted = false
    @State private var elementResizeStarted = false
    @State private var gridSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            if viewModel.isGridBackground {
                GridBackgroundView(gridBackgroundViewModel: gridBackgroundViewModel)
            }
            Group {
                Canvas(rendersAsynchronously: true) { context, size in
                    viewModel.render(&context, size: size)
                }
                .onTapGesture { tapLocation in
                    viewModel.selectItem(at: tapLocation)
                }
                if viewModel.selectedElement != nil {
                    if viewModel.selectedElement is UMLElement {
                        SelectedElementView(viewModel: viewModel, elementMoveStarted: $elementMoveStarted, elementResizeStarted: $elementResizeStarted)
                    } else if viewModel.selectedElement is UMLRelationship {
                        SelectedRelationshipView(viewModel: viewModel)
                    }
                }
                //Rectangle().stroke(.blue, lineWidth: 1)
            }.frame(width: max(viewModel.diagramSize.width + 1, viewModel.currentDiagramSize.width + 1),
                    height: max(viewModel.diagramSize.height + 1, viewModel.currentDiagramSize.height + 1))
        }.scaleEffect(viewModel.scale * viewModel.progressingScale)
            .position(viewModel.currentDragLocation)
            .onAppear{
                self.gridSize = CGSize(width: viewModel.geometrySize.width * 10, height: viewModel.geometrySize.height * 10)
                gridBackgroundViewModel.gridSize = self.gridSize
                viewModel.setDragLocation()
            }.onChange(of: viewModel.currentDiagramSize) {
                viewModel.calculateIdealScale()
            }.gesture(
                !elementMoveStarted && !elementResizeStarted ?
                DragGesture()
                    .onChanged(handleDrag)
                    .onEnded { _ in
                        dragStarted = true
                    }
                : nil
            ).simultaneousGesture(
                !elementMoveStarted && !elementResizeStarted ?
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
