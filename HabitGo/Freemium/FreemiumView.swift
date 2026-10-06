//
//  FreemiumView.swift
//  HabitArcFlow
//
//  Freemium Tier UI (100 welcome credits + daily sign-in bonus + optional paywall)
//

import SwiftUI

struct FreemiumView: View {
    @StateObject private var viewModel = FreemiumViewModel()
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("Free Tier Active")
                                .font(.headline)
                                .foregroundColor(.green)
                            Spacer()
                            Text("VIP Lv.\(viewModel.vipLevel)")
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.15))
                                .cornerRadius(8)
                        }

                        Divider()

                        HStack {
                            Label("Available Credits", systemImage: "bolt.circle.fill")
                            Spacer()
                            Text("\(viewModel.credits)")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                        }

                        HStack {
                            Text("Daily Sign-in (+10 pts):")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button {
                                Task { await viewModel.signIn() }
                            } label: {
                                Text(viewModel.signedInToday ? "Collected" : "Claim Now")
                                    .font(.subheadline.bold())
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.signedInToday)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Membership & Quota")
                } footer: {
                    Text("Every new device receives 100 welcome credits. All local habit tracking features remain 100% free forever.")
                }

                Section("Upgrade (Optional)") {
                    Button {
                        showingPaywall = true
                    } label: {
                        HStack {
                            Label("Explore Premium & Cloud Sync", systemImage: "sparkles")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Credits & Tier")
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

@MainActor
class FreemiumViewModel: ObservableObject {
    @Published var credits: Int = BuyservicesClient.freeTier.creditsOnRegister
    @Published var vipLevel: Int = BuyservicesClient.freeTier.vipLevelAuto
    @Published var signedInToday: Bool = false

    func signIn() async {
        guard !signedInToday else { return }
        credits += BuyservicesClient.freeTier.signinDaily
        signedInToday = true
    }
}
