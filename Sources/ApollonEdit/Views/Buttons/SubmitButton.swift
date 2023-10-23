import SwiftUI

struct SubmitButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.blue)
                
                Text("Submit")
                    .foregroundColor(.white)
                    .padding(5)
            }
        }
    }
}
