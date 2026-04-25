import SwiftUI

struct HabitStackView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showAddChain = false

    var body: some View {
        NavigationStack {
            List {
                if habitChains.isEmpty {
                    emptyState
                } else {
                    chainsSection
                }
            }
            .navigationTitle("Habit Stacks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddChain = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddChain) {
                AddHabitChainView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "link.circle")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "34C759").opacity(0.6))

            Text("Build Habit Chains")
                .font(.headline)

            Text("Link habits together using the Atomic Habits methodology.\n\n\"After I [HABIT], I will [NEW HABIT]\"")
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                showAddChain = true
            } label: {
                Label("Create First Chain", systemImage: "plus")
                    .font(.headline)
                    .padding()
                    .background(Color(hex: "34C759"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .listRowBackground(Color.clear)
    }

    private var chainsSection: some View {
        Section("Active Chains") {
            ForEach(habitChains) { chain in
                if let anchor = habitVM.habits.first(where: { $0.id == chain.anchorHabitId }),
                   let linked = habitVM.habits.first(where: { $0.id == chain.linkedHabitId }) {
                    chainRow(anchor: anchor, linked: linked, chain: chain)
                }
            }
            .onDelete(perform: deleteChain)
        }
    }

    private func chainRow(anchor: Habit, linked: Habit, chain: HabitChain) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Anchor Habit
                VStack {
                    Image(systemName: anchor.icon)
                        .font(.title2)
                        .foregroundColor(Color(hex: anchor.colorHex))
                        .frame(width: 44, height: 44)
                        .background(Color(hex: anchor.colorHex).opacity(0.2))
                        .clipShape(Circle())

                    Text(anchor.name)
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                        .lineLimit(1)
                }

                // Arrow
                VStack {
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(Color(hex: "34C759"))

                    Text("AFTER")
                        .font(.caption2.bold())
                        .foregroundColor(Color(hex: "34C759"))
                }
                .padding(.horizontal, 8)

                // Linked Habit
                VStack {
                    Image(systemName: linked.icon)
                        .font(.title2)
                        .foregroundColor(Color(hex: linked.colorHex))
                        .frame(width: 44, height: 44)
                        .background(Color(hex: linked.colorHex).opacity(0.2))
                        .clipShape(Circle())

                    Text(linked.name)
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                        .lineLimit(1)
                }

                Spacer()

                // Status
                if anchor.isCompletedToday {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(colorScheme == .dark ? Color(hex: "38383A") : Color(hex: "E9ECEF"))
                }
            }

            // Progress indicator
            if !anchor.isCompletedToday {
                Text("Complete \"\(anchor.name)\" first to unlock \"\(linked.name)\"")
                    .font(.caption2)
                    .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
            } else if linked.isCompletedToday {
                Text("Chain completed! 🎉")
                    .font(.caption)
                    .foregroundColor(.green)
            } else {
                Text("Now do \"\(linked.name)\"!")
                    .font(.caption)
                    .foregroundColor(Color(hex: "007AFF"))
            }
        }
        .padding(.vertical, 8)
    }

    private var habitChains: [HabitChain] {
        // Load from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: "HabitGo_chains"),
              let chains = try? JSONDecoder().decode([HabitChain].self, from: data) else {
            return []
        }
        return chains
    }

    private func deleteChain(at offsets: IndexSet) {
        var chains = habitChains
        chains.remove(atOffsets: offsets)
        if let data = try? JSONEncoder().encode(chains) {
            UserDefaults.standard.set(data, forKey: "HabitGo_chains")
        }
    }
}

struct AddHabitChainView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedAnchorId: UUID?
    @State private var selectedLinkedId: UUID?

    var body: some View {
        NavigationStack {
            Form {
                Section("Anchor Habit (First)") {
                    ForEach(habitVM.habits) { habit in
                        Button {
                            selectedAnchorId = habit.id
                        } label: {
                            HStack {
                                Image(systemName: habit.icon)
                                    .foregroundColor(Color(hex: habit.colorHex))
                                Text(habit.name)
                                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                                Spacer()
                                if selectedAnchorId == habit.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(hex: "34C759"))
                                }
                            }
                        }
                    }
                }

                Section("Linked Habit (Then)") {
                    ForEach(habitVM.habits.filter { $0.id != selectedAnchorId }) { habit in
                        Button {
                            selectedLinkedId = habit.id
                        } label: {
                            HStack {
                                Image(systemName: habit.icon)
                                    .foregroundColor(Color(hex: habit.colorHex))
                                Text(habit.name)
                                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                                Spacer()
                                if selectedLinkedId == habit.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(hex: "34C759"))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Chain")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChain()
                    }
                    .disabled(selectedAnchorId == nil || selectedLinkedId == nil)
                }
            }
        }
    }

    private func saveChain() {
        guard let anchorId = selectedAnchorId, let linkedId = selectedLinkedId else { return }

        let chain = HabitChain(anchorHabitId: anchorId, linkedHabitId: linkedId)
        var chains: [HabitChain] = []

        if let data = UserDefaults.standard.data(forKey: "HabitGo_chains"),
           let existing = try? JSONDecoder().decode([HabitChain].self, from: data) {
            chains = existing
        }

        chains.append(chain)

        if let data = try? JSONEncoder().encode(chains) {
            UserDefaults.standard.set(data, forKey: "HabitGo_chains")
        }

        dismiss()
    }
}

#Preview {
    HabitStackView()
        .environmentObject(HabitViewModel())
}