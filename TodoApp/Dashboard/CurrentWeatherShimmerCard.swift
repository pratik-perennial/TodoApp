import SwiftUI

struct CurrentWeatherShimmerCard: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    // Weather icon placeholder
                    Circle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 48, height: 48)

                    // Wind row placeholder
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.28))
                        .frame(width: 120, height: 14)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    // Temperature placeholder
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 120, height: 48)

                    // Condition description placeholder
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.28))
                        .frame(width: 140, height: 18)
                }
            }

            // Hourly row placeholder
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { _ in
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.35))
                                .frame(width: 40, height: 24)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.28))
                                .frame(width: 40, height: 12)
                        }
                        .padding(.vertical, 6)
                        .frame(width: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.15))
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue)
        )
        .padding(.horizontal)
        .shimmer()
    }
}

// MARK: - Shimmer Modifier
private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    let width = max(geo.size.width, 1)
                    let gradient = LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    Rectangle()
                        .fill(gradient)
                        .rotationEffect(.degrees(20))
                        .offset(x: phase * (width * 2))
                        .frame(width: width * 1.2)
                        .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: phase)
                }
                .allowsHitTesting(false)
                .mask(content)
            )
            .onAppear {
                // Start the shimmer sweep
                phase = 1
            }
    }
}

private extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

#Preview {
    ZStack {
        Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
        CurrentWeatherShimmerCard()
    }
}
