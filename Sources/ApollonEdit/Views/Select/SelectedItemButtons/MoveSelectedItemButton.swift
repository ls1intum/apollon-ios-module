import SwiftUI

struct MoveSelectedItemButton: View {    
    var body: some View {
        Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
            .frame(width: 35, height: 35)
            .foregroundColor(.white)
            .padding(5)
            .background {
                Circle()
                    .foregroundColor(.blue)
            }
    }
}
