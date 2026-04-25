import SwiftUI

struct HabitTemplatesView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedCategory: String = "All"
    @State private var searchText = ""

    private var categories: [String] {
        var cats = Set(HabitTemplate.templates.map { $0.category })
        cats.insert("All")
        return ["All"] + cats.sorted()
    }

    private var filteredTemplates: [HabitTemplate] {
        var templates = HabitTemplate.templates
        if selectedCategory != "All" {
            templates = templates.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            templates = templates.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return templates
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button {
                                selectedCategory = cat
                            } label: {
                                Text(cat)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(
                                        selectedCategory == cat
                                            ? ThemeManager.AppColors.primary
                                            : (colorScheme == .dark ? ThemeManager.AppColors.darkTertiaryBG : ThemeManager.AppColors.lightTertiaryBG)
                                    )
                                    .foregroundStyle(selectedCategory == cat ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                List(filteredTemplates) { template in
                    TemplateRow(template: template) {
                        let habit = template.toHabit()
                        habitVM.addHabit(
                            name: habit.name,
                            icon: habit.icon,
                            colorHex: habit.colorHex,
                            frequency: habit.frequency,
                            reminderHour: habit.reminderHour,
                            reminderMinute: habit.reminderMinute,
                            reminderEnabled: habit.reminderEnabled
                        )
                        dismiss()
                    }
                }
                .listStyle(.plain)
            }
            .searchable(text: $searchText, prompt: "Search templates")
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
        }
    }
}

struct TemplateRow: View {
    let template: HabitTemplate
    let onSelect: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(hex: template.colorHex).opacity(0.15))
                        .frame(width: 48, height: 48)
                    Text(template.icon)
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.body.bold())
                        .foregroundStyle(.primary)
                    Text(template.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    HStack {
                        Text(template.category)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: template.colorHex).opacity(0.15))
                            .foregroundStyle(Color(hex: template.colorHex))
                            .clipShape(Capsule())
                        Text(template.frequency.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(ThemeManager.AppColors.primary)
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
    }
}
