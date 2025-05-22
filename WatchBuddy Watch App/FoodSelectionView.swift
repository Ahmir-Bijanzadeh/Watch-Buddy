// FoodSelectionView.swift

import SwiftUI

struct FoodSelectionView: View {
    @ObservedObject var pet: PetModel
    @Environment(\.dismiss) var dismiss

    var onFoodSelectedAndDismissParent: (() -> Void)?

    var body: some View {
        VStack {
            Text("Choose Food")
                .font(.headline)
                .padding(.bottom) // Keeps space below the title

            ForEach(FoodType.allCases) { foodType in
                let quantity = pet.foodInventory[foodType] ?? 0
                Button {
                    pet.activeAction = .feed
                    pet.selectedFoodType = foodType
                    dismiss()
                    onFoodSelectedAndDismissParent?()
                } label: {
                    HStack {
                        Text(foodType.rawValue)
                        Spacer()
                        Text("(\(quantity))")
                    }
                }
                .disabled(quantity == 0)
                .padding(.vertical, 0)
            }
            .padding(.bottom, 3)

            Button("Cancel") {
                dismiss()
            }
            .tint(.red)
        }
        .padding(.top, 30) // ADJUSTED: Increased top padding to 30
    }
}

#Preview {
    FoodSelectionView(pet: PetModel())
}
