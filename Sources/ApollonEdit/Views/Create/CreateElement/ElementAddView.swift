import SwiftUI
import ApollonShared

struct ElementAddView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.flexible(), spacing: 3)]) {
                ForEach(viewModel.diagramType.diagramElementTypes, id: \.self) { type in
                    addElement(for: type)
                        .padding(5)
                }
            }
        }
        .frame(maxHeight: viewModel.geometrySize.height / 8)
    }
    
    private func addElement(for type: UMLElementType) -> some View {
        Button {
            viewModel.addElement(type: type)
        } label: {
            Image(type.rawValue, bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}
