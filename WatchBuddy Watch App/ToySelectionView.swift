//
//  ToySelectionView.swift
//  WatchBuddy
//
//  Created by Ahmir on 5/20/25.
//


// ToySelectionView.swift

import SwiftUI

struct ToySelectionView: View {
    @ObservedObject var pet: PetModel
    @Environment(\.dismiss) var dismiss // To dismiss this sheet

    var onToySelectedAndDismissParent: (() -> Void)?

    var body: some View {
        VStack { // Using default VStack spacing for now.
            Text("Choose Toy") // Title for the toy menu
                .font(.headline)
                .padding(.bottom, 3) // Adjusted bottom padding for title

            ForEach(ToyType.allCases) { toyType in // Iterate through toy types
                let quantity = pet.toyInventory[toyType] ?? 0
                Button {
                    pet.activeAction = .play          // Set action to play
                    pet.selectedToyType = toyType   // Store the specific toy type
                    dismiss()                         // Dismiss this toy selection sheet
                    onToySelectedAndDismissParent?()  // Call to dismiss PetControlView
                } label: {
                    HStack {
                        Text(toyType.rawValue)
                        Spacer()
                        Text("(\(quantity))") // Show quantity
                    }
                }
                .disabled(quantity == 0) // Disable button if quantity is 0
                .padding(.vertical, 0) // Vertical padding for each button
            }
            .padding(.bottom, 3) // Bottom padding for the ForEach block

            Button("Cancel") {
                dismiss() // Just dismiss this sheet
            }
            .tint(.red)
        }
        .padding(.top, 30) // Overall top padding for the VStack
    }
}

#Preview {
    ToySelectionView(pet: PetModel())
}