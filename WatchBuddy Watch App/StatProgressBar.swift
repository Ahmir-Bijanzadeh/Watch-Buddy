// StatProgressBar.swift

import SwiftUI

struct StatProgressBar: View {
    let title: String // Still needed for accessibility label and percentage display context
    let value: Double
    let color: Color

    var body: some View {
        // Removed the HStack and the explicit Text(title) on the left
        // The ProgressView will now naturally expand to fill available width.
        ProgressView(value: value, total: 100.0) {
            // This label is important for accessibility, even if not visually prominent
            Text(title) // This text is now the hidden label for the progress view
        } currentValueLabel: {
            // This is the visible percentage value
            Text("\(Int(value))%")
        }
        .progressViewStyle(.linear)
        .tint(color)
    }
}

#Preview {
    VStack(spacing: 1) {
        StatProgressBar(title: "test1", value: 75.5, color: .red)
        StatProgressBar(title: "test2", value: 25.2, color: .green)
        StatProgressBar(title: "test3", value: 90.8, color: .blue)
        StatProgressBar(title: "test4", value: 40.1, color: .purple)
    }
}
