import SwiftUI
import ApollonShared

struct UMLRendererView: View {
    @ObservedObject var viewModel: ApollonViewViewModel
    @StateObject var gridBackgroundViewModel = GridBackgroundViewModel()

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
                //Rectangle().stroke(.blue, lineWidth: 1)
            }
            .frame(width: viewModel.umlModel.size?.width ?? 1, height: viewModel.umlModel.size?.height ?? 1)
        }
        .scaleEffect(viewModel.scale * viewModel.progressingScale)
        .position(viewModel.currentDragLocation)
        .onAppear{
            gridSize = CGSize(width: viewModel.geometrySize.width * 5, height: viewModel.geometrySize.height * 5)
            gridBackgroundViewModel.gridSize = gridSize
            gridBackgroundViewModel.showGridBackgroundBorder = true
            viewModel.setDragLocation()
        }.gesture(
            viewModel.isGridBackground ?
            DragGesture()
                .onChanged(viewModel.handleDiagramDrag)
                .onEnded { _ in
                    viewModel.dragStarted = true
                }
            : nil
        ).simultaneousGesture(
            viewModel.isGridBackground ?
            MagnificationGesture()
                .onChanged(viewModel.handleDiagramMagnification)
                .onEnded(viewModel.handleDiagramMagnificationEnd)
            : nil
        )
    }
}
