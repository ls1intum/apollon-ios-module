import SwiftUI
import SharedModels

struct FeedbackViewPopOver: View {
    @ObservedObject var viewModel: ApollonFeedbackViewModel
    @Binding var showFeedback: Bool
    
    var body: some View {
        if showFeedback,
           viewModel.selectedElement != nil,
           let feedbackId = viewModel.selectedFeedbackId,
           let feedback = viewModel.getFeedback(byId: feedbackId){
            VStack {
                Spacer()
                HStack {
                    VStack {
                        if let reference = feedback.reference {
                            Text(reference.components(separatedBy: ":")[0])
                                .foregroundColor(.white)
                                .bold()
                        }
                        if let text = feedback.text {
                            Text("Feedback: \(text)")
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        if let points = feedback.credits {
                            Text("Points: \(String(points))")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .center)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(getBackgroundColor(feedback: feedback))
                }
                .animation(.easeInOut(duration: 0.5), value: showFeedback)
            }
            .padding([.leading, .bottom, .trailing], 20)
        }
    }
    
    private func getBackgroundColor(feedback: Feedback) -> Color {
        if let credits = feedback.credits {
            if credits > 0.0 {
                return .green
            }
            if credits < 0.0 {
                return .red
            }
        }
        return .gray
    }
}
