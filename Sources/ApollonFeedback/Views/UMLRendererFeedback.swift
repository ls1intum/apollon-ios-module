import SwiftUI
import ApollonShared

struct UMLRendererFeedback: View {
    @ObservedObject var viewModel: ApollonFeedbackViewModel
    @StateObject var gridBackgroundViewModel = GridBackgroundViewModel()

    var body: some View {
        if viewModel.isGridBackground {
            ZStack {
                GridBackgroundView(gridBackgroundViewModel: gridBackgroundViewModel)
                Group {
                    Canvas(rendersAsynchronously: true) { context, size in
                        viewModel.render(&context, size: size)
                    }
                    Canvas(rendersAsynchronously: true) { context, size in
                        viewModel.renderHighlights(&context, size: size)
                    } symbols: {
                        viewModel.generatePossibleSymbols()
                    }
                    .onTapGesture { tapLocation in
                        viewModel.selectItem(at: tapLocation)
                    }
                }
                .frame(width: (viewModel.umlModel.size?.width ?? 1) + 30, height: (viewModel.umlModel.size?.height ?? 1) + 30)
            }
            .scaleEffect(viewModel.scale * viewModel.progressingScale)
            .position(viewModel.currentDragLocation)
            .onAppear{
                gridBackgroundViewModel.gridSize = CGSize(width: viewModel.geometrySize.width * 7, height: viewModel.geometrySize.height * 7)
                gridBackgroundViewModel.showGridBackgroundBorder = true
                viewModel.setDragLocation()
            }.gesture(
                DragGesture()
                    .onChanged(viewModel.handleDiagramDrag)
                    .onEnded { _ in
                        viewModel.dragStarted = true
                    }
            ).simultaneousGesture(
                MagnificationGesture()
                    .onChanged(viewModel.handleDiagramMagnification)
                    .onEnded(viewModel.handleDiagramMagnificationEnd)
            )
        } else {
            ZStack {
                Group {
                    Canvas(rendersAsynchronously: true) { context, size in
                        viewModel.render(&context, size: size)
                    }
                    Canvas(rendersAsynchronously: true) { context, size in
                        viewModel.renderHighlights(&context, size: size)
                    } symbols: {
                        viewModel.generatePossibleSymbols()
                    }
                }
                .frame(width: viewModel.umlModel.size?.width, height: viewModel.umlModel.size?.height)
            }
        }
    }
}
