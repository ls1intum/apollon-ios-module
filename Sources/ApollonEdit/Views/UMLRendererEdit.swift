import SwiftUI
import Common

struct UMLRendererEdit: View {
    @StateObject public var viewModel: ApollonEditViewModel
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            viewModel.getGridBackground()
                .resizable(resizingMode: .tile)
            Group {
                Canvas(rendersAsynchronously: true) { context, size in
                    viewModel.render(&context, size: size)
                }
            }
        }
    }
}
