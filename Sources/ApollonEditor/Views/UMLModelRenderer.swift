import SwiftUI

struct UMLModelRenderer: View {
    @StateObject var diagramViewModel: DiagramViewModel
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            viewModel.loadGridBackgroundImage()
                .resizable(resizingMode: .tile)
            Group {
                Canvas(rendersAsynchronously: true) { context, size in
                    diagramViewModel.render(&context, size: size)
                }
            }
        }
    }
}
