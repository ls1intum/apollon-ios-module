import SwiftUI
import ApollonShared

struct UMLRendererView: View {
    @StateObject public var viewModel: ApollonViewViewModel
    @StateObject var gridBackgroundViewModel = GridBackgroundViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
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
