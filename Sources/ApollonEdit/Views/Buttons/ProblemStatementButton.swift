import SwiftUI

struct ProblemStatementButton: View {
    @StateObject var viewModel: ApollonEditViewModel
    @State private var isShowingProblemStatement: Bool = false
    
    var body: some View {
        Button {
            isShowingProblemStatement.toggle()
        } label: {
            Image(systemName: "newspaper")
                .frame(width: 25, height: 25)
                .foregroundColor(.white)
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.blue)
                }
        }.sheet(isPresented: $isShowingProblemStatement) {}
    }
}
