import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var categories: [HabitCategory] = HabitCategory.defaultCategories
    @State private var showAddCategory = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach($categories) { $category in
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: category.colorHex).opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Text(category.icon)
                                    .font(.body)
                            }
                            Text(category.name)
                                .font(.body)
                            Spacer()
                        }
                        .padding(.vertical, 2)
                        .listRowBackground(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
                    }
                    .onDelete { indexSet in
                        categories.remove(atOffsets: indexSet)
                    }

                    Button {
                        showAddCategory = true
                    } label: {
                        Label("Add Category", systemImage: "plus.circle.fill")
                            .foregroundStyle(ThemeManager.AppColors.primary)
                    }
                    .listRowBackground(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        habitVM.saveCategories(categories)
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView { newCategory in
                    categories.append(newCategory)
                }
            }
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
        }
    }
}

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "#34C759"

    let onAdd: (HabitCategory) -> Void

    private let icons = ThemeManager.AppColors.habitIcons
    private let colors = ThemeManager.AppColors.habitColors

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category Name", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.2) : Color.clear)
                                        .frame(width: 36, height: 36)
                                    Text(icon)
                                        .font(.title3)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: color))
                                        .frame(width: 32, height: 32)
                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let category = HabitCategory(name: name, icon: selectedIcon, colorHex: selectedColor)
                        onAdd(category)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}


