import SwiftUI

struct ElementAddView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    
    var body: some View {
        HStack {
            ForEach(viewModel.diagramType.diagramElementTypes, id: \.self) { type in
                Button {
                    viewModel.addElement(type: type)
                } label: {
                    Image(type.rawValue, bundle: .module)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }.padding(3)
        }.frame(maxHeight: viewModel.geometrySize.height / 15)
    }
}
