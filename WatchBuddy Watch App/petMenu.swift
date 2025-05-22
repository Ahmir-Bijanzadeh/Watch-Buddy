// PetControlView.swift

import SwiftUI

struct PetControlView: View {
    @ObservedObject var pet: PetModel
    var gameScene: PetGameScene
    @Environment(\.dismiss) var dismiss

    @State private var showingFoodSelection = false
    // NEW: State to control the presentation of the toy selection sheet
    @State private var showingToySelection = false

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Button("Feed") {
                        showingFoodSelection = true
                    }
                    Button("Play") {
                        // MODIFIED: Show the toy selection sheet
                        showingToySelection = true
                    }
                    Button("Clean") {
                        pet.activeAction = .clean
                        dismiss()
                    }
                }
                .padding(.bottom, 10)

                VStack(alignment: .leading, spacing: 5) {
                    StatProgressBar(title: "Hunger", value: pet.hunger, color: .red)
                    StatProgressBar(title: "Happiness", value: pet.happiness, color: .green)
                    StatProgressBar(title: "Cleanliness", value: pet.cleanliness, color: .blue)
                    StatProgressBar(title: "Sleepiness", value: pet.sleepiness, color: .purple)

                    StatProgressBar(title: "Running", value: pet.runningLevel, color: .orange)
                    StatProgressBar(title: "Swimming", value: pet.swimmingLevel, color: .mint)
                    StatProgressBar(title: "Cycling", value: pet.cyclingLevel, color: .yellow)

                    Button("Sleep") {
                        pet.activeAction = .sleep
                        dismiss()
                    }
                    .padding(.top, 10)
                }
                .font(.footnote)

                Button("Return to Pet") {
                    dismiss()
                }
                .padding(.top, 10)
                .tint(.secondary)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Pet Controls")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingFoodSelection) {
            FoodSelectionView(pet: pet) {
                self.dismiss()
            }
        }
        // NEW: Present ToySelectionView as a sheet
        .sheet(isPresented: $showingToySelection) {
            ToySelectionView(pet: pet) {
                self.dismiss()
            }
        }
    }
}

#Preview {
    PetControlView(pet: PetModel(), gameScene: PetGameScene())
}
