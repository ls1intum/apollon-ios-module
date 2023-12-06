import SwiftUI
import ApollonShared

struct UMLRendererView<Content: View>: View {
    @ObservedObject var viewModel: ApollonViewViewModel
    @StateObject var gridBackgroundViewModel = GridBackgroundViewModel()
    @ViewBuilder var content: Content

    var body: some View {
        if viewModel.isGridBackground {
            ZStack {
                GridBackgroundView(gridBackgroundViewModel: gridBackgroundViewModel)
                Group {
                    Canvas(rendersAsynchronously: true) { context, size in
                        viewModel.render(&context, size: size)
                    }
                    content
                    Rectangle().stroke(.blue, lineWidth: 1)
                }
                .frame(width: viewModel.umlModel.size?.width, height: viewModel.umlModel.size?.height)
            }
            .scaleEffect(viewModel.scale * viewModel.progressingScale)
            .position(viewModel.currentDragLocation)
            .onAppear{
                gridBackgroundViewModel.gridSize = CGSize(width: viewModel.geometrySize.width * 7, height: viewModel.geometrySize.height * 7)
                gridBackgroundViewModel.showGridBackgroundBorder = true
                viewModel.setDragLocation()
            }
            .gesture(
                DragGesture()
                    .onChanged(viewModel.handleDiagramDrag)
                    .onEnded { _ in
                        viewModel.dragStarted = true
                    }
            )
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged(viewModel.handleDiagramMagnification)
                    .onEnded(viewModel.handleDiagramMagnificationEnd)
            )
        } else {
            ZStack {
                Canvas(rendersAsynchronously: true) { context, size in
                    viewModel.render(&context, size: size)
                }
                .frame(width: viewModel.umlModel.size?.width ?? 1, height: viewModel.umlModel.size?.height ?? 1)
            }
        }
    }
}
