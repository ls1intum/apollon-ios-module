import SwiftUI

struct UMLModelRenderer: View {
    @StateObject var diagramViewModel: DiagramViewModel
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("UMLGridBackground", bundle: .module)
                .resizable(resizingMode: .tile)
            Group {
                Canvas(rendersAsynchronously: true) { context, size in
                    diagramViewModel.render(&context, size: size)
                }
            }
        }
    }
}
