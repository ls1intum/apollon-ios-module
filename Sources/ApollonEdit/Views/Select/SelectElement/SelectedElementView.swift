import SwiftUI
import ApollonShared

struct SelectedElementView: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Binding var elementDragStarted: Bool
    
    var body: some View {
        if let bounds = viewModel.selectedElementBounds {
            ZStack {
                Rectangle() //SELECTED ITEM
                    .stroke(Color.blue, lineWidth: 5)
                    .opacity(0.5)
                    .frame(width: bounds.width, height: bounds.height)
                    .position(x: bounds.x + (bounds.width / 2), y: bounds.y + (bounds.height / 2))
                Circle() // UP
                    .trim(from: 0.5, to: 1)
                    .fill(Color.blue)
                    .opacity(elementDragStarted ? 0 : 0.5)
                    .frame(width: 40, height: 40)
                    .position(x: bounds.x + (bounds.width / 2), y: bounds.y)
                Circle() // DOWN
                    .trim(from: 0, to: 0.5)
                    .fill(Color.blue)
                    .opacity(elementDragStarted ? 0 : 0.5)
                    .frame(width: 40, height: 40)
                    .position(x: bounds.x + (bounds.width / 2), y: bounds.y + bounds.height)
                Circle() // LEFT
                    .trim(from: 0.25, to: 0.75)
                    .fill(Color.blue)
                    .opacity(elementDragStarted ? 0 : 0.5)
                    .frame(width: 40, height: 40)
                    .position(x: bounds.x, y: bounds.y + (bounds.height / 2))
                Circle() // RIGHT
                    .trim(from: 0.5, to: 1)
                    .rotation(.degrees(90))
                    .fill(Color.blue)
                    .opacity(elementDragStarted ? 0 : 0.5)
                    .frame(width: 40, height: 40)
                    .position(x: bounds.x + bounds.width, y: bounds.y + (bounds.height / 2))
                MoveSelectedItemButton(viewModel: viewModel)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                elementDragStarted = true
                                viewModel.moveSelectedItemButton(position: value.location)
                                viewModel.selectedElementBounds?.x = value.location.x
                                viewModel.selectedElementBounds?.y = value.location.y
                            }
                            .onEnded { value in
                                elementDragStarted = false
                                viewModel.moveSelectedItemButton()
                                viewModel.updateElementPosition(location: value.location)
                            }
                    )
                if !elementDragStarted {
                    EditSelectedItemButton(viewModel: viewModel)
                    ResizeSelectedItemButton(viewModel: viewModel)
                }
            }
        }
    }
}
