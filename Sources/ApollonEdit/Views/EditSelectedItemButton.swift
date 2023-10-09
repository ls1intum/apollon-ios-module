import SwiftUI

struct EditSelectedItemButton: View {
    @StateObject var viewModel: ApollonEditViewModel
    @State private var isShowingPopup: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            Button {
                isShowingPopup.toggle()
            } label: {
                HStack {
                    Text("Edit")
                        .foregroundColor(Color.primary)
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color.primary)
                        .symbolRenderingMode(.hierarchical)
                }
            }.frame(width: 75, height: 50)
                .padding(2)
                .foregroundColor(Color(UIColor.systemBackground))
                .background(Color.blue)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .position(x: geometry.size.width / 2, y: geometry.size.height / 1.05)
                .sheet(isPresented: $isShowingPopup) {
                    ElementEditPopUpView(viewModel: viewModel, isShowingPopup: $isShowingPopup)
                }
        }
    }
}
