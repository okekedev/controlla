//
//  OnboardingView.swift
//  Controlla
//
//  First-launch onboarding with setup instructions
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.6, blue: 1.0),
                    Color(red: 0.6, green: 0.4, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo
                Image("Controlla")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .cornerRadius(25)
                    .shadow(radius: 15)

                // Welcome title
                VStack(spacing: 12) {
                    Text("Welcome to Controlla")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)

                    Text("Control your Mac wirelessly")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.9))
                }

                // Setup instructions
                VStack(alignment: .leading, spacing: 25) {
                    InstructionStep(
                        number: "1",
                        title: "Download on Mac",
                        description: "Install Controlla on your Mac from the App Store"
                    )

                    InstructionStep(
                        number: "2",
                        title: "Open on Both Devices",
                        description: "Launch Controlla on your Mac and on this device"
                    )

                    InstructionStep(
                        number: "3",
                        title: "Connect",
                        description: "Tap the Devices tab and select your Mac"
                    )
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 35)
                .background(Color.white.opacity(0.15))
                .cornerRadius(20)
                .padding(.horizontal, 30)

                Spacer()

                // Get Started button
                Button(action: {
                    dismiss()
                }) {
                    Text("Get Started")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 1.0))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

struct InstructionStep: View {
    let number: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Number circle
            Text(number)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 1.0))
                .frame(width: 40, height: 40)
                .background(Color.white)
                .cornerRadius(20)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}
