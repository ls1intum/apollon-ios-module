import SwiftUI
import ApollonShared

struct UMLRendererEdit: View {
    @ObservedObject var viewModel: ApollonEditViewModel
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
                Rectangle().stroke(.blue, lineWidth: 1)
            }.frame(width: max(viewModel.umlModel.size?.width ?? 1, viewModel.initialDiagramSize.width),
                    height: max(viewModel.umlModel.size?.height ?? 1, viewModel.initialDiagramSize.height))
        }.scaleEffect(viewModel.scale * viewModel.progressingScale)
            .position(viewModel.currentDragLocation)
            .onAppear{
                gridSize = CGSize(width: viewModel.geometrySize.width * 8, height: viewModel.geometrySize.height * 8)
                gridBackgroundViewModel.gridSize = gridSize
                gridBackgroundViewModel.showGridBackgroundBorder = true
                viewModel.setDragLocation()
            }.onChange(of: viewModel.initialDiagramSize) {
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
