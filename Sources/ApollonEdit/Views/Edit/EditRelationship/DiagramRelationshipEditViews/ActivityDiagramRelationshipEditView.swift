import SwiftUI
import ApollonShared

struct ActivityDiagramRelationshipEditView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var relationshipName: String

    var body: some View {
        HStack {
            Text("Control Flow")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Button {
                if let relationship = (viewModel.selectedElement as? UMLRelationship) {
                    relationship.switchSourceAndTarget()
                    viewModel.updateRelationshipPosition()
                }
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(viewModel.themeColor)
            }
            .frame(width: 25, height: 25)

            Button {
                viewModel.removeSelectedItem()
                isShowingPopup = false
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(viewModel.themeColor)
            }.frame(width: 25, height: 25)

            Button("Done") {
                isShowingPopup = false
                viewModel.selectedElement = nil
                viewModel.adjustDiagramSize()
                viewModel.updateRelationshipPosition()
            }
            .padding(5)
            .foregroundColor(Color(UIColor.systemBackground))
            .background(viewModel.themeColor)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(viewModel.themeColor, lineWidth: 1)
            )
        }.padding([.leading, .top, .trailing], 15)

        EditDivider()

        TextField("", text: $relationshipName)
            .textFieldStyle(PopUpTextFieldStyle())
            .padding([.leading, .trailing], 15)
    }
}
