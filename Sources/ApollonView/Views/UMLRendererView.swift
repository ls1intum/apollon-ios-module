import SwiftUI

public struct UMLRendererView: View {
    @StateObject public var viewModel: ApollonViewViewModel
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            viewModel.loadGridBackgroundImage()
                .resizable(resizingMode: .tile)
            Group {
                Canvas(rendersAsynchronously: true) { context, size in
                    viewModel.render(&context, size: size)
                }
            }
        }
    }
}
