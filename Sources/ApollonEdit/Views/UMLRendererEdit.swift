import SwiftUI
import ApollonShared

struct UMLRendererEdit: View {
    @StateObject public var viewModel: ApollonEditViewModel
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.isGridBackground {
                GridBackgroundView()
            }
            Group {
                Canvas(rendersAsynchronously: true) { context, size in
                    viewModel.render(&context, size: size)
                }
            }
        }
    }
}
