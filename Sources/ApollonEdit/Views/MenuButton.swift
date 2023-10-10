import SwiftUI

struct MenuButton: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Menu {
            Button("Problem Statement") {
                
            }
            Menu("Add Element") {
                ForEach(viewModel.diagramType?.diagramElementTypes ?? [], id: \.self) { type in
                    Button(type.rawValue) {
                        viewModel.addElement(type: type)
                    }
                }
            }
            Button("Submit & Exit"){
                presentationMode.wrappedValue.dismiss()
            }
        } label: {
            Image(systemName: "gearshape.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
                .padding(5)
                .symbolRenderingMode(.hierarchical)
        }
    }
}
