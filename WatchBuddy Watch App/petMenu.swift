// PetControlView.swift

import SwiftUI

struct PetControlView: View {
    @ObservedObject var pet: PetModel
    var gameScene: PetGameScene
    @Environment(\.dismiss) var dismiss

    @State private var showingFoodSelection = false
    @State private var showingToySelection = false
    @State private var showingKillConfirmation = false
    @State private var showingEvoView = false // State for presenting evoView
    @State private var showingResetConfirmation = false // NEW: State for reset confirmation

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

                    // Evolve Button - opens evoView
                    Button("Evolve") {
                        showingEvoView = true // Show the evolution view
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.green) // Make "Evolve" button green for emphasis

                    Button("Kill") {
                        showingKillConfirmation = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.red)

                    // NEW: Reset Data Button
                    Button("Reset Data") {
                        showingResetConfirmation = true // Show reset confirmation
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.orange) // Give it a distinctive color
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
        // NEW: Sheet for Evolve View
        .sheet(isPresented: $showingEvoView) {
            EvoView() // Present the evolution view
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
        // NEW: Confirmation dialog for "Reset Data" button
        .confirmationDialog("Are you sure you want to reset all data?",
                            isPresented: $showingResetConfirmation,
                            titleVisibility: .visible) {
            Button("Confirm Reset", role: .destructive) {
                pet.resetUser() // Reset all pet data
                dismiss()
            }
            Button("Cancel", role: .cancel) {
                // Do nothing
            }
        } message: {
            Text("This will reset your pet points, inventory, and evolution progress.")
        }
    }
}

#Preview {
    PetControlView(pet: PetModel(), gameScene: PetGameScene())
}
