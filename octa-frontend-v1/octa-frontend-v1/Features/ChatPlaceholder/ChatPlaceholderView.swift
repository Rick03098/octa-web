import SwiftUI

struct ChatPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("聊天功能即将上线")
                .font(DSFonts.serifMedium(22))
            Text("这里将展示 AI 对话体验，敬请期待。")
                .font(DSFonts.serifRegular(16))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

#Preview {
    ChatPlaceholderView()
}
