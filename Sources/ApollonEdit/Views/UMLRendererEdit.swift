import SwiftUI
import ApollonCommon

struct UMLRendererEdit: View {
    @StateObject public var viewModel: ApollonEditViewModel
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.isGridBackground {
                ApollonEditViewModel.getGridBackground()
            }
            Group {
                Canvas(rendersAsynchronously: true) { context, size in
                    viewModel.render(&context, size: size)
                }
            }
        }
    }
}
