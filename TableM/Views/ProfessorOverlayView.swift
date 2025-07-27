import SwiftUI

struct ProfessorOverlayView: View {
    @ObservedObject var playerProgress: PlayerProgressViewModel
    
    let message: String
    let isOnboarding: Bool
    let onNext: () -> Void
    let onSkip: () -> Void
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    if !isOnboarding {
                        dismissWithAnimation()
                    }
                }
            
            VStack {
                Spacer()
                
                // Professor and speech bubble
                VStack {
                    HStack {
                        Spacer()
                        speechBubbleView
                    }
                    
                    professorImageView
                }
                .offset(x: -100, y: 100)
            }
            .ignoresSafeArea()
        }
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                isVisible = true
            }
        }
    }
    
    // MARK: - Professor Image
    private var professorImageView: some View {
        Image(playerProgress.getSelectedSkinImageName())
            .resizable()
            .scaledToFit()
            .frame(height: 450)
    }
    
    // MARK: - Speech Bubble
    private var speechBubbleView: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Message text
            Text(message)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            // Buttons for onboarding mode
            if isOnboarding {
                onboardingButtons
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.indigo.opacity(0.8))
        )
        .overlay(
            // Speech bubble tail
            speechBubbleTail,
            alignment: .bottomLeading
        )
        .frame(maxWidth: 280)
    }
    
    // MARK: - Onboarding Buttons
    private var onboardingButtons: some View {
        HStack(spacing: 12) {
            // Skip button
            Button(action: {
                dismissWithAnimation()
                onSkip()
            }) {
                Text("Skip")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.2))
                            .shadow(color: .black, radius: 1, x: 0.5, y: 0.5)
                    )
            }
            
            Spacer()
            
            // Next button
            Button(action: {
                onNext()
            }) {
                HStack(spacing: 6) {
                    Text("Next")
                        .font(.system(size: 12, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.indigo)
                        .shadow(color: .black, radius: 1, x: 0.5, y: 0.5)
                )
            }
        }
    }
    
    // MARK: - Speech Bubble Tail
    private var speechBubbleTail: some View {
        Path { path in
            path.move(to: CGPoint(x: 20, y: 0))
            path.addLine(to: CGPoint(x: 20, y: 15))
            path.addLine(to: CGPoint(x: 40, y: 0))
            path.closeSubpath()
        }
        .fill(Color.indigo.opacity(0.8))
        .frame(width: 50, height: 20)
        .offset(x: 20, y: 20)
    }
    
    // MARK: - Animation Helper
    private func dismissWithAnimation() {
        withAnimation(.easeIn(duration: 0.2)) {
            isVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        ProfessorOverlayView(
            playerProgress: PlayerProgressViewModel(),
            message: "Welcome! I'm Professor Logicus, your guide through this logical adventure.",
            isOnboarding: true,
            onNext: { print("Next pressed") },
            onSkip: { print("Skip pressed") },
            onDismiss: { print("Dismissed") }
        )
    }
}
