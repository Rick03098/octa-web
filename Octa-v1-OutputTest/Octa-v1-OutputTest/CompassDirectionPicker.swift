import SwiftUI

struct CompassDirectionPicker: View {
    @Binding var selectedDirection: CompassDirection

    var body: some View {
        VStack(spacing: 16) {
            CompassDial(direction: $selectedDirection)
                .frame(height: 220)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(CompassDirection.allCases) { direction in
                    Button {
                        withAnimation(.easeInOut) {
                            selectedDirection = direction
                        }
                    } label: {
                        Text(direction.promptValue)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedDirection == direction ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1))
                            .foregroundColor(selectedDirection == direction ? Color.accentColor : Color.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct CompassDial: View {
    @Binding var direction: CompassDirection
    @State private var indicatorAngle: Double = 0

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ZStack {
                Circle()
                    .fill(Color.secondary.opacity(0.08))
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 2)

                ForEach(CompassDirection.allCases) { dir in
                    let angle = Angle(degrees: dir.angle)
                    VStack {
                        Text(dir.promptValue)
                            .font(.footnote)
                            .foregroundColor(dir == direction ? Color.accentColor : Color.secondary)
                            .rotationEffect(-angle)
                            .padding(.bottom, size * 0.35)
                        Spacer()
                    }
                    .rotationEffect(angle)
                }

                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: 4, height: size * 0.4)
                    .offset(y: -size * 0.2)
                    .rotationEffect(Angle(degrees: indicatorAngle))

                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 12, height: 12)
            }
            .contentShape(Circle())
            .gesture(dragGesture(center: center))
            .onAppear {
                indicatorAngle = direction.angle
            }
            .onChange(of: direction) { newValue in
                withAnimation(.easeInOut) {
                    indicatorAngle = newValue.angle
                }
            }
        }
    }

    private func dragGesture(center: CGPoint) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let angle = angleFor(location: value.location, center: center)
                indicatorAngle = angle
                direction = CompassDirection.direction(from: angle)
            }
            .onEnded { _ in
                withAnimation(.easeInOut) {
                    indicatorAngle = direction.angle
                }
            }
    }

    private func angleFor(location: CGPoint, center: CGPoint) -> Double {
        let dx = location.x - center.x
        let dy = location.y - center.y
        var radians = atan2(dx, -dy) // convert so 0 is up (north)
        var degrees = radians * 180 / .pi
        if degrees < 0 { degrees += 360 }
        return degrees
    }
}

#Preview {
    StatefulPreviewWrapper(CompassDirection.north) { binding in
        CompassDirectionPicker(selectedDirection: binding)
            .padding()
    }
}

private struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
