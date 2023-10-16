import SwiftUI

struct SelectedRelationshipView: View {
    @StateObject var viewModel: ApollonEditViewModel
    
    var body: some View {
        if let bounds = viewModel.selectedElementBounds {
            ZStack {
                Rectangle() //SELECTED ITEM
                    .stroke(Color.blue, lineWidth: 5)
                    .opacity(0.5)
                    .frame(width: bounds.width, height: bounds.height)
                    .position(x: bounds.x + (bounds.width / 2), y: bounds.y + (bounds.height / 2))
                EditSelectedItemButton(viewModel: viewModel)
            }
        }
    }
}
