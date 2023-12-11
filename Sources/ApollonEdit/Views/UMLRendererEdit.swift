import SwiftUI
import ApollonShared

struct UMLRendererEdit: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @StateObject var gridBackgroundViewModel = GridBackgroundViewModel()

    @State private var elementMoveStarted = false
    @State private var elementResizeStarted = false

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
            }
            .frame(width: max(viewModel.umlModel.size?.width ?? 1, viewModel.initialDiagramSize.width),
                   height: max(viewModel.umlModel.size?.height ?? 1, viewModel.initialDiagramSize.height))
        }
        .scaleEffect(viewModel.scale * viewModel.progressingScale)
        .position(viewModel.currentDragLocation)
        .onAppear{
            gridBackgroundViewModel.gridSize = CGSize(width: viewModel.geometrySize.width * 8, height: viewModel.geometrySize.height * 8)
            gridBackgroundViewModel.showGridBackgroundBorder = true
            gridBackgroundViewModel.gridBackgroundBorderColor = viewModel.themeColor
            viewModel.setDragLocation()
        }.onChange(of: viewModel.initialDiagramSize) {
            viewModel.calculateIdealScale()
        }.gesture(
            !elementMoveStarted && !elementResizeStarted ?
            DragGesture()
                .onChanged(viewModel.handleDiagramDrag)
                .onEnded { _ in
                    viewModel.dragStarted = true
                }
            : nil
        ).simultaneousGesture(
            !elementMoveStarted && !elementResizeStarted ?
            MagnificationGesture()
                .onChanged(viewModel.handleDiagramMagnification)
                .onEnded(viewModel.handleDiagramMagnificationEnd)
            : nil
        )
    }
}
