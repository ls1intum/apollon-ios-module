import SwiftUI

struct ElementEditTopBar: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    
    var body: some View {
        HStack {
            Text("Edit Element")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer ()
            
            Button("Done") {
                isShowingPopup = false
                viewModel.selectedElement = nil
            }.padding(10)
                .foregroundColor(Color(UIColor.systemBackground))
                .background(Color.blue)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.blue, lineWidth: 1)
                )
        }.padding([.leading, .top, .trailing], 15)
    }
}

struct SimpleElementEditView: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var elementName: String
    
    var body: some View {
        HStack {
            TextField("Element Name", text: $elementName)
                .textFieldStyle(PopUpTextFieldStyle())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            Button {
                viewModel.removeSelectedItem()
                isShowingPopup = false
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.blue)
            }.frame(width: 30, height: 30)
        }.padding([.leading, .trailing], 15)
    }
}

struct RoundedButtonStyle: ButtonStyle {
    let selected: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(selected ? Color(UIColor.systemBackground) : Color.blue)
            .background(selected ? Color.blue : Color.clear)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.blue, lineWidth: 1)
            )
    }
}

struct PopUpTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background(Color(UIColor.systemBackground))
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.primary, lineWidth: 1)
            )
    }
}

struct DottedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background(Color(UIColor.systemBackground))
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.primary, style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
    }
}
