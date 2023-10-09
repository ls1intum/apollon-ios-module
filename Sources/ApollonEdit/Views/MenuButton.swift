import SwiftUI

struct MenuButton: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        GeometryReader { geometry in
                Menu {
                    Button("Submit & Exit"){
                        presentationMode.wrappedValue.dismiss()
                    }
                    Menu("Add Element") {
                        ForEach(viewModel.diagramType?.diagramElementTypes ?? [], id: \.self) { type in
                            Button(type.rawValue) {
                                viewModel.addElement(type: type)
                            }
                        }
                    }
                    Button("Problem Statement") {
                        
                    }
                } label: {
                    Image(systemName: "info.circle.fill")
                        .resizable()
                        .frame(width: 75, height: 75)
                        .foregroundColor(Color.blue)
                        .symbolRenderingMode(.hierarchical)
                }.frame(width: 75, height: 75)
                    .position(x: geometry.size.width / 1.2, y: geometry.size.height / 1.05)
        }
    }
}
