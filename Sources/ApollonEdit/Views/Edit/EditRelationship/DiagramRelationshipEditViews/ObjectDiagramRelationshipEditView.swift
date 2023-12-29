import SwiftUI
import ApollonShared

struct ObjectDiagramRelationshipEditView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool

    var body: some View {
        HStack {
            Text("Relationship")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

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
    }
}
