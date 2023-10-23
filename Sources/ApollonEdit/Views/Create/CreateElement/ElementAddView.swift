import SwiftUI

struct ElementAddView: View {
    @StateObject var viewModel: ApollonEditViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.diagramType?.diagramElementTypes ?? [], id: \.self) { type in
                Button {
                    viewModel.addElement(type: type)
                } label: {
                    Image(type.rawValue, bundle: .module)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        }.frame(maxWidth: viewModel.geometrySize.width / 3, maxHeight: viewModel.geometrySize.height / 3)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(.gray)
        }.padding(5)
    }
}
