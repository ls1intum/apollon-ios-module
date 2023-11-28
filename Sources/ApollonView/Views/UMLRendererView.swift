import SwiftUI
import ApollonShared

struct UMLRendererView: View {
    @ObservedObject var viewModel: ApollonViewViewModel
    @StateObject var gridBackgroundViewModel = GridBackgroundViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.isGridBackground {
                    GridBackgroundView(gridBackgroundViewModel: gridBackgroundViewModel)
                }
                Group {
                    Canvas(rendersAsynchronously: true) { context, size in
                        viewModel.render(&context, size: size)
                    }
                }
                .frame(width: viewModel.umlModel.size?.width ?? 1, height: viewModel.umlModel.size?.height ?? 1)
            }.onAppear {
                gridBackgroundViewModel.gridSize = CGSize(width: geometry.size.width * 2, height: geometry.size.height * 2)
            }
        }
    }
}
