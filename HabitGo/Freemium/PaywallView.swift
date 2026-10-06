//
//  PaywallView.swift
//  HabitArcFlow
//
//  Self-Service Paywall (PayPal Subscription, Credit Packages, BYO OpenAI Key)
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var openAIKey = ""
    @State private var isSavedKey = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Premium Subscription") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Unlimited Habit Arcs & Multi-Device Sync")
                            .font(.headline)
                        Text("Unlock all premium themes, encrypted iCloud backup export, and priority AI recommendations.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)

                    Button {
                        // Action for PayPal / Stripe checkout
                    } label: {
                        HStack {
                            Text("Monthly Pass")
                            Spacer()
                            Text("$4.99 / mo")
                                .bold()
                        }
                    }

                    Button {
                        // Action for Annual checkout
                    } label: {
                        HStack {
                            Text("Annual Pass (Best Value)")
                            Spacer()
                            Text("$29.99 / yr")
                                .bold()
                        }
                    }
                }

                Section("Credit Packs") {
                    HStack {
                        Text("1,000 AI Credits")
                        Spacer()
                        Button("$4.99") {}
                            .buttonStyle(.bordered)
                    }
                    HStack {
                        Text("5,000 AI Credits")
                        Spacer()
                        Button("$19.99") {}
                            .buttonStyle(.bordered)
                    }
                }

                Section("Bring Your Own API Key (Optional)") {
                    SecureField("OpenAI API Key (sk-...)", text: $openAIKey)
                    Button {
                        isSavedKey = true
                    } label: {
                        Text(isSavedKey ? "Key Saved to Keychain" : "Save Key")
                    }
                    .disabled(openAIKey.isEmpty)
                }

                Section {
                    Text("Payment processed securely via PayPal & Stripe. Terms of Service and Privacy Policy apply.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Upgrade Options")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
