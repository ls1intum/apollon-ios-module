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
            }.onAppear {
                gridBackgroundViewModel.gridSize = CGSize(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
