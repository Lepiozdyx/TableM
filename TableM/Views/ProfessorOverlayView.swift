import SwiftUI

struct ProfessorOverlayView: View {
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
                HStack(alignment: .bottom, spacing: 20) {
                    // Professor image
                    professorImageView
                    
                    Spacer()
                    
                    // Speech bubble
                    speechBubbleView
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
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
        Image("professor_logicus")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 140, height: 180)
    }
    
    // MARK: - Speech Bubble
    private var speechBubbleView: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Message text
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            // Buttons for onboarding mode
            if isOnboarding {
                onboardingButtons
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue.opacity(0.9))
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
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.2))
                    )
            }
            
            Spacer()
            
            // Next button
            Button(action: {
                onNext()
            }) {
                HStack(spacing: 6) {
                    Text("Next")
                        .font(.system(size: 14, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                )
            }
        }
    }
    
    // MARK: - Speech Bubble Tail
    private var speechBubbleTail: some View {
        Path { path in
            path.move(to: CGPoint(x: 25, y: 0))
            path.addLine(to: CGPoint(x: 15, y: 15))
            path.addLine(to: CGPoint(x: 40, y: 10))
            path.closeSubpath()
        }
        .fill(Color.blue.opacity(0.9))
        .frame(width: 50, height: 20)
        .offset(x: 10, y: 10)
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
            message: "Welcome to Table M! I'm Professor Logicus, your guide through this logical adventure.",
            isOnboarding: true,
            onNext: { print("Next pressed") },
            onSkip: { print("Skip pressed") },
            onDismiss: { print("Dismissed") }
        )
    }
}

// MARK: - Regular Message Preview
#Preview("Regular Message") {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        ProfessorOverlayView(
            message: "Excellent deduction! Your logical thinking is impressive.",
            isOnboarding: false,
            onNext: { },
            onSkip: { },
            onDismiss: { print("Dismissed") }
        )
    }
}
