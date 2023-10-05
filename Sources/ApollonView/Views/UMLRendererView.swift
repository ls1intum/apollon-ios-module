import SwiftUI
import ApollonCommon

struct UMLRendererView: View {
    @StateObject public var viewModel: ApollonViewViewModel
    
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
