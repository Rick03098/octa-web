import SwiftUI

struct OrientationCaptureView: View {
    @ObservedObject var controller: OrientationCaptureController

    init(controller: OrientationCaptureController) {
        self.controller = controller
    }

    var body: some View {
        ZStack {
            VideoLoopView(resourceName: "orientation_background", resourceExtension: "mov")
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 0.86, green: 0.94, blue: 1.0),
                    Color(red: 0.98, green: 0.97, blue: 0.94)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(0.55)

            VStack(spacing: 24) {
                Spacer().frame(height: 80)

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 220, height: 220)
                        .shadow(color: Color.black.opacity(0.1), radius: 25, y: 10)

                    Circle()
                        .trim(from: 0, to: CGFloat(controller.progress))
                        .stroke(Color(red: 0.29, green: 0.41, blue: 0.72), lineWidth: 8)
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 8) {
                        Text(String(format: "%.0f°", controller.currentAngle))
                            .font(DSFonts.serifMedium(36))
                            .foregroundStyle(Color(red: 0.16, green: 0.2, blue: 0.32))
                        Text(controller.isCompleted ? DSStrings.OrientationCapture.completed : DSStrings.OrientationCapture.recording)
                            .font(DSFonts.serifRegular(16))
                            .foregroundStyle(Color(red: 0.3, green: 0.32, blue: 0.4))
                    }
                }

                VStack(spacing: 8) {
                    Text(DSStrings.OrientationCapture.title)
                        .font(DSFonts.serifMedium(24))
                    Text(DSStrings.OrientationCapture.subtitle)
                        .font(DSFonts.serifRegular(16))
                        .foregroundStyle(Color(red: 0.3, green: 0.33, blue: 0.42))
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onAppear { controller.start() }
        .onDisappear { controller.stop() }
    }
}

#Preview {
    OrientationCaptureView(controller: OrientationCaptureController(flowState: UserOnboardingFlowState()))
}
