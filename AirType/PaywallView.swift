//
//  PaywallView.swift
//  Controlla
//
//  Pro subscription paywall
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.4, blue: 0.9),
                    Color(red: 0.5, green: 0.5, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Title
                VStack(spacing: 12) {
                    Text("Unlock Pro Features")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("Get full control of your Mac")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                }

                // Feature list
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(icon: "keyboard", title: "Text Input", description: "Type anywhere on your Mac")
                    FeatureRow(icon: "command", title: "Keyboard Actions", description: "Enter, Backspace, and Space keys")
                    FeatureRow(icon: "sparkles", title: "Full Productivity", description: "Complete keyboard control")
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 30)
                .background(Color.white.opacity(0.15))
                .cornerRadius(20)
                .padding(.horizontal, 30)

                // Pricing
                VStack(spacing: 12) {
                    Text("7-Day Free Trial")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("Then $0.99/month")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))

                    Text("Cancel anytime • Family Sharing")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }

                // Subscribe button
                if let product = storeManager.products.first {
                    Button(action: {
                        Task {
                            do {
                                let success = try await storeManager.purchase(product)
                                if success {
                                    dismiss()
                                }
                            } catch {
                                print("❌ Purchase error: \(error)")
                            }
                        }
                    }) {
                        Group {
                            if storeManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.5, green: 0.5, blue: 1.0)))
                            } else {
                                Text("Start Free Trial")
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 1.0))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 30)
                    .disabled(storeManager.isLoading)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }

                // Restore button
                Button(action: {
                    Task {
                        await storeManager.restorePurchases()
                        if storeManager.isPro {
                            dismiss()
                        }
                    }
                }) {
                    Text("Restore Purchases")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .disabled(storeManager.isLoading)

                Spacer()

                // Privacy and Terms links
                HStack(spacing: 20) {
                    Link("Privacy Policy", destination: URL(string: "https://okekedev.github.io/controlla/privacy.html")!)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))

                    Text("•")
                        .foregroundColor(.white.opacity(0.4))

                    Link("Terms of Use", destination: URL(string: "https://okekedev.github.io/controlla/terms.html")!)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 8)

                // Close button (for free users who want to use joystick only)
                Button(action: {
                    dismiss()
                }) {
                    Text("Continue with Free Version")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
    }
}
