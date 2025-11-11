import SwiftUI

struct CaptureCompleteView: View {
    @ObservedObject var controller: CaptureCompleteController
    @State private var isVisible = true

    init(controller: CaptureCompleteController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            VideoLoopView(resourceName: "orientation_background", resourceExtension: "mov")
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.84, blue: 0.85),
                    Color(red: 0.99, green: 0.96, blue: 0.93)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(0.65)

            VStack(spacing: 12) {
                Spacer()

                Text(DSStrings.CaptureComplete.title)
                    .font(DSFonts.serifMedium(28))
                    .foregroundStyle(Color(red: 0.2, green: 0.21, blue: 0.28))
                Text(DSStrings.CaptureComplete.subtitle)
                    .font(DSFonts.serifRegular(16))
                    .foregroundStyle(Color(red: 0.3, green: 0.31, blue: 0.38))

                Spacer()
            }
            .padding()
        }
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            controller.startCountdown()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isVisible = false
                }
            }
        }
        .onDisappear { controller.cancel() }
    }
}

#Preview {
    CaptureCompleteView(controller: CaptureCompleteController())
}
