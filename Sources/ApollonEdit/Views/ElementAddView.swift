import SwiftUI

struct ElementAddView: View {
    @StateObject var viewModel: ApollonEditViewModel
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(viewModel.diagramType?.diagramElementTypes ?? [], id: \.self) { type in
                Button {
                    viewModel.addElement(type: type)
                } label: {
                    Image(type.rawValue, bundle: .module)
                        .resizable()
                        .frame(width: 75, height: 75)
                }
            }
        }.background {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(.gray)
        }
    }
}
