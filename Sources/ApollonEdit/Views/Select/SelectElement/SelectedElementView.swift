import SwiftUI
import ApollonShared

struct SelectedElementView: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Binding var elementMoveStarted: Bool
    @Binding var elementResizeStarted: Bool
    
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
                    .opacity(elementMoveStarted || elementResizeStarted ? 0 : 0.5)
                    .frame(width: 40, height: 40)
                    .position(x: bounds.x + (bounds.width / 2), y: bounds.y)
                Circle() // DOWN
                    .trim(from: 0, to: 0.5)
                    .fill(Color.blue)
                    .opacity(elementMoveStarted || elementResizeStarted ? 0 : 0.5)
                    .frame(width: 40, height: 40)
                    .position(x: bounds.x + (bounds.width / 2), y: bounds.y + bounds.height)
                Circle() // LEFT
                    .trim(from: 0.25, to: 0.75)
                    .fill(Color.blue)
                    .opacity(elementMoveStarted || elementResizeStarted ? 0 : 0.5)
                    .frame(width: 40, height: 40)
                    .position(x: bounds.x, y: bounds.y + (bounds.height / 2))
                Circle() // RIGHT
                    .trim(from: 0.5, to: 1)
                    .rotation(.degrees(90))
                    .fill(Color.blue)
                    .opacity(elementMoveStarted || elementResizeStarted ? 0 : 0.5)
                    .frame(width: 40, height: 40)
                    .position(x: bounds.x + bounds.width, y: bounds.y + (bounds.height / 2))
                if !elementResizeStarted {
                    MoveSelectedItemButton(viewModel: viewModel)
                        .position(CGPoint(x: bounds.x - 25, y: bounds.y + (bounds.height + 25)))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    elementMoveStarted = true
                                    viewModel.selectedElementBounds?.x = value.location.x + 25
                                    viewModel.selectedElementBounds?.y = value.location.y - (bounds.height + 25)
                                }
                                .onEnded { value in
                                    viewModel.updateElementPosition(location: CGPoint(x: value.location.x + 25, y: value.location.y - (bounds.height + 25)))
                                    viewModel.adjustDiagramSizeForSelectedElement()
                                    elementMoveStarted = false
                                    viewModel.selectedElement = nil
                                }
                        )
                }
                if !elementMoveStarted {
                    ResizeSelectedItemButton(viewModel: viewModel)
                        .position(CGPoint(x: bounds.x + (bounds.width + 25), y: bounds.y + (bounds.height + 25)))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    elementResizeStarted = true
                                    viewModel.selectedElementBounds?.width = (viewModel.selectedElement?.bounds?.width ?? 0) + value.translation.width
                                }
                                .onEnded { value in
                                    viewModel.updateElementSize(drag: value.translation)
                                    viewModel.adjustDiagramSizeForSelectedElement()
                                    elementResizeStarted = false
                                    viewModel.selectedElement = nil
                                }
                        )
                }
                if !elementMoveStarted && !elementResizeStarted {
                    EditSelectedItemButton(viewModel: viewModel)
                        .position(CGPoint(x: bounds.x + (bounds.width / 2), y: bounds.y - 50))
                }
            }
        }
    }
}
