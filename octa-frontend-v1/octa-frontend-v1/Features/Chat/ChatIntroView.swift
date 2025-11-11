import SwiftUI

struct ChatIntroView: View {
    let userName: String
    var onPrompt: ((String) -> Void)?
    var onCompose: (() -> Void)?

    private let prompts = [
        DSStrings.ChatIntro.prompt1,
        DSStrings.ChatIntro.prompt2,
        DSStrings.ChatIntro.prompt3
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    Color(red: 0.82, green: 0.92, blue: 1.0),
                    Color(red: 0.97, green: 0.98, blue: 0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text(DSStrings.ChatIntro.greeting(name: userName))
                    .font(DSFonts.serifMedium(32))
                    .foregroundStyle(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, y: 4)

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(prompts, id: \.self) { prompt in
                        Button {
                            onPrompt?(prompt)
                        } label: {
                            Text(prompt)
                                .font(DSFonts.serifRegular(16))
                                .foregroundStyle(Color(red: 0.2, green: 0.22, blue: 0.3))
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()

                messageInput
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
    }

    private var messageInput: some View {
        HStack(spacing: 12) {
            Button(action: { onCompose?() }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(red: 0.2, green: 0.23, blue: 0.34))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
            }

            TextField(DSStrings.ChatIntro.placeholder, text: .constant(""))
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(Color.white.opacity(0.92))
                .clipShape(Capsule())

            Button(action: { onCompose?() }) {
                Image(systemName: "waveform")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(red: 0.2, green: 0.23, blue: 0.34))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    ChatIntroView(userName: "Rick")
}
