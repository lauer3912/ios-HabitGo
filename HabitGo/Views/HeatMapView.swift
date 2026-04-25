import SwiftUI

struct HeatMapView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.colorScheme) private var colorScheme

    let months: Int = 6

    private var heatMapData: [[HeatMapDay]] {
        var data: [[HeatMapDay]] = []
        let calendar = Calendar.current
        let today = Date()

        for weekOffset in (0..<53).reversed() {
            var week: [HeatMapDay] = []
            for dayOffset in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: -(weekOffset * 7) + dayOffset, to: today) else {
                    continue
                }
                let key = Habit.dayKey(from: date)
                let completionCount = habitVM.habits.filter { $0.completions[key] == true }.count
                let totalHabits = habitVM.habits.count
                let day = HeatMapDay(id: key, date: date, completionCount: completionCount, totalHabits: totalHabits)
                week.append(day)
            }
            data.append(week)
        }
        return data
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    statsSummary
                    monthLabels
                    heatMapGrid
                    legend
                    monthlyBreakdown
                }
                .padding()
            }
            .navigationTitle("Heat Map")
            .background(colorScheme == .dark ? Color.black : Color(hex: "F8F9FA"))
        }
    }

    private var statsSummary: some View {
        HStack(spacing: 16) {
            summaryCard(title: "Active Days", value: "\(activeDays)", color: Color(hex: "34C759"))
            summaryCard(title: "Best Streak", value: "\(bestStreak)", color: Color(hex: "FF9500"))
            summaryCard(title: "Completion", value: "\(Int(overallCompletionRate * 100))%", color: Color(hex: "007AFF"))
        }
    }

    private func summaryCard(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(colorScheme == .dark ? Color(hex: "141414") : Color.white)
        .cornerRadius(12)
    }

    private var monthLabels: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(Array(monthHeaders.enumerated()), id: \.offset) { _, month in
                    Text(month)
                        .font(.caption2)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                        .frame(width: 14)
                }
            }
        }
    }

    private var monthHeaders: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let calendar = Calendar.current
        var months: [String] = []
        for i in (0..<12).reversed() {
            if let date = calendar.date(byAdding: .month, value: -i, to: Date()) {
                months.append(formatter.string(from: date))
            }
        }
        return months
    }

    private var heatMapGrid: some View {
        VStack(spacing: 3) {
            ForEach(0..<7, id: \.self) { row in
                HStack(spacing: 3) {
                    ForEach(0..<min(heatMapData.count, 53), id: \.self) { col in
                        if row < heatMapData[col].count {
                            let day = heatMapData[col][row]
                            Rectangle()
                                .fill(Color(hex: day.colorHex))
                                .frame(width: 12, height: 12)
                                .cornerRadius(2)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 12, height: 12)
                        }
                    }
                }
            }
        }
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Less")
                .font(.caption2)
                .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))

            HStack(spacing: 4) {
                ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { level in
                    Rectangle()
                        .fill(Color(hex: dayColorHex(for: level)))
                        .frame(width: 12, height: 12)
                        .cornerRadius(2)
                }
            }

            Text("More")
                .font(.caption2)
                .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
        }
        .padding()
        .background(colorScheme == .dark ? Color(hex: "141414") : Color.white)
        .cornerRadius(12)
    }

    private func dayColorHex(for level: Double) -> String {
        switch level {
        case 0: return "#E9ECEF"
        case 0.25: return "#0E4429"
        case 0.5: return "#26A641"
        case 0.75: return "#39D353"
        default: return "#006D32"
        }
    }

    private var monthlyBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Overview")
                .font(.headline)

            ForEach(monthData, id: \.month) { data in
                HStack {
                    Text(data.month)
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)

                    Spacer()

                    Text("\(data.completed)/\(data.total)")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(colorScheme == .dark ? Color(hex: "1E1E1E") : Color(hex: "E9ECEF"))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "34C759"))
                                .frame(width: geo.size.width * data.rate)
                        }
                    }
                    .frame(width: 60, height: 8)
                }
                .padding()
                .background(colorScheme == .dark ? Color(hex: "141414") : Color.white)
                .cornerRadius(8)
            }
        }
    }

    private var monthData: [(month: String, completed: Int, total: Int, rate: Double)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let calendar = Calendar.current

        return (0..<6).reversed().compactMap { monthOffset in
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) else { return nil }
            let monthName = formatter.string(from: monthDate)

            var completed = 0
            var total = 0

            let components = calendar.dateComponents([.year, .month], from: monthDate)
            guard let startOfMonth = calendar.date(from: components),
                  let range = calendar.range(of: .day, in: .month, for: monthDate) else { return nil }

            for day in range {
                guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { continue }
                let key = Habit.dayKey(from: date)
                completed += habitVM.habits.filter { $0.completions[key] == true }.count
                total += habitVM.habits.count
            }

            let rate = total > 0 ? Double(completed) / Double(total) : 0
            return (monthName, completed, total, rate)
        }
    }

    private var activeDays: Int {
        var days = Set<String>()
        for habit in habitVM.habits {
            for key in habit.completions.keys where habit.completions[key] == true {
                days.insert(key)
            }
        }
        return days.count
    }

    private var bestStreak: Int {
        habitVM.habits.map { $0.longestStreak }.max() ?? 0
    }

    private var overallCompletionRate: Double {
        let totalPossible = habitVM.habits.count * 90
        let totalCompleted = habitVM.habits.reduce(0) { $0 + $1.totalCompletions }
        return totalPossible > 0 ? Double(totalCompleted) / Double(totalPossible) : 0
    }
}

#Preview {
    HeatMapView()
        .environmentObject(HabitViewModel())
}