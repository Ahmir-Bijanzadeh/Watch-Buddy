//
//  RenamePetView.swift
//  WatchBuddy
//
//  Created by Ahmir on 5/20/25.
//


// RenamePetView.swift

import SwiftUI

struct RenamePetView: View {
    @ObservedObject var pet: PetModel // To directly update the pet's name
    @Environment(\.dismiss) var dismiss // To dismiss this sheet

    @State private var newName: String // State to hold the current input in the TextField

    // Custom initializer to set the initial value of newName from pet.petName
    init(pet: PetModel) {
        self.pet = pet
        _newName = State(initialValue: pet.petName)
    }

    var body: some View {
        VStack {
            Text("Rename Your Buddy")
                .font(.headline)
                .padding(.bottom, 10)

            // TextField for the user to type the new name
            TextField("New Name", text: $newName)
                .textInputAutocapitalization(.words) // Capitalizes first letter of each word
                .autocorrectionDisabled() // Optional: Disable autocorrection for names
                .padding(.horizontal)

            HStack {
                // Cancel button
                Button("Cancel") {
                    dismiss() // Dismiss the sheet without saving changes
                }
                .tint(.red) // Make the cancel button red

                // Save button
                Button("Save") {
                    // Only update if the input is not empty or just whitespace
                    if !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        pet.petName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    dismiss() // Dismiss the sheet after saving
                }
                .tint(.green) // Make the save button green
            }
            .padding(.top, 10)
        }
        .padding()
        // Optional: Hide navigation elements in the sheet for a cleaner look
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

// Preview provider for RenamePetView
#Preview {
    RenamePetView(pet: PetModel())
}