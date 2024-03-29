import SwiftUI
import ApollonShared

struct UMLRendererView<Content: View>: View {
    @ObservedObject var viewModel: ApollonViewViewModel
    @StateObject var gridBackgroundViewModel = GridBackgroundViewModel()
    @State var isPreview: Bool
    @ViewBuilder var extraContent: Content

    var body: some View {
        if !isPreview {
            ZStack {
                if viewModel.isGridBackground {
                    GridBackgroundView(gridBackgroundViewModel: gridBackgroundViewModel)
                }
                Group {
                    Canvas(rendersAsynchronously: true) { context, size in
                        viewModel.render(&context, size: size)
                    }
                    extraContent
                }
                .frame(width: (viewModel.umlModel.size?.width ?? 1) + (viewModel.diagramOffset.x * 2), height: (viewModel.umlModel.size?.height ?? 1) + (viewModel.diagramOffset.y * 2))
            }
            .scaleEffect(viewModel.scale * viewModel.progressingScale)
            .position(viewModel.currentDragLocation)
            .onAppear{
                gridBackgroundViewModel.gridSize = CGSize(width: viewModel.geometrySize.width * 8, height: viewModel.geometrySize.height * 8)
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
                .frame(width: (viewModel.umlModel.size?.width ?? 1) + (viewModel.diagramOffset.x * 2), height: (viewModel.umlModel.size?.height ?? 1) + (viewModel.diagramOffset.y * 2))
            }
            .scaleEffect(viewModel.scale * viewModel.progressingScale)
            .position(viewModel.currentDragLocation)
            .onAppear{
                viewModel.setDragLocation()
            }
            .gesture(
                DragGesture()
                    .onChanged(viewModel.handleDiagramDrag)
                    .onEnded { _ in
                        viewModel.dragStarted = true
                    }
            )
        } 
    }
}
