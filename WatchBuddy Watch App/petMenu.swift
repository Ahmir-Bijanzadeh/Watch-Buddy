// PetControlView.swift

import SwiftUI

struct PetControlView: View {
    @ObservedObject var pet: PetModel
    var gameScene: PetGameScene
    @Environment(\.dismiss) var dismiss

    @State private var showingFoodSelection = false
    @State private var showingToySelection = false
    @State private var showingKillConfirmation = false // NEW: State for kill confirmation

    // Define a flexible grid layout for two columns
    private let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack {
                // Use LazyVGrid to arrange buttons in a 2x3 grid
                LazyVGrid(columns: gridItemLayout, spacing: 10) {
                    Button("Feed") {
                        showingFoodSelection = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Play") {
                        showingToySelection = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Clean") {
                        pet.activeAction = .clean
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Sleep") {
                        pet.activeAction = .sleep
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    // "Kill" button
                    Button("Kill") {
                        showingKillConfirmation = true // Trigger confirmation dialog
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.red) // Make "Kill" button red for emphasis

                    // "Evolve" button (functionality to be added later)
                    Button("Evolve") {
                        print("✨ Evolve button pressed!")
                        // For now, just dismiss the view. Evolution logic to be added.
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.green) // Make "Evolve" button green for emphasis
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Pet Actions")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingFoodSelection) {
            FoodSelectionView(pet: pet) {
                self.dismiss()
            }
        }
        .sheet(isPresented: $showingToySelection) {
            ToySelectionView(pet: pet) {
                self.dismiss()
            }
        }
        // NEW: Confirmation dialog for "Kill" button
        .confirmationDialog("Are you sure you want to kill your pet?",
                            isPresented: $showingKillConfirmation,
                            titleVisibility: .visible) {
            Button("Confirm Kill", role: .destructive) {
                pet.resetStats() // Reset all pet stats
                dismiss() // Return to the main pet screen (ContentView)
            }
            Button("Cancel", role: .cancel) {
                // Do nothing, dialog will dismiss
            }
        } message: {
            Text("This action cannot be undone and will reset all your pet's progress.")
        }
    }
}

#Preview {
    PetControlView(pet: PetModel(), gameScene: PetGameScene())
}
