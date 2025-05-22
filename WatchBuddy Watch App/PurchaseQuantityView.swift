//
//  PurchaseQuantityView.swift
//  WatchBuddy
//
//  Created by Ahmir on 5/21/25.
//


//
//  PurchaseQuantityView.swift
//  WatchBuddy
//
//  Created by Ahmir on 5/21/25.
//

import SwiftUI

struct PurchaseQuantityView: View {
    @ObservedObject var pet: PetModel // To access petPoints and update inventory
    @Environment(\.dismiss) var dismiss // To dismiss this sheet

    let itemName: String // The name of the item (e.g., "Kibble", "Ball")
    let itemPrice: Int   // The price of a single unit of the item
    let maxQuantity: Int // Max quantity to prevent over-purchase or excessive cost

    // Closure to execute when the purchase is confirmed
    // It will receive the quantity purchased
    var onConfirm: ((Int) -> Void)?

    @State private var quantity: Int = 1 // Counter for the quantity to purchase

    // Computed property to calculate the total cost
    private var totalCost: Int {
        quantity * itemPrice
    }

    var body: some View {
        VStack {
            Text("Purchase \(itemName)")
                .font(.headline)
                .padding(.bottom, 10)

            // Quantity Counter
            HStack {
                Button {
                    if quantity > 1 {
                        quantity -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                }
                .disabled(quantity <= 1) // Disable if quantity is 1 or less
                .tint(.red)

                Text("\(quantity)")
                    .font(.largeTitle)
                    .frame(minWidth: 50) // Give it a fixed width to prevent jumpiness
                    .contentTransition(.numericText()) // Smooth transition for number changes

                Button {
                    if quantity < maxQuantity && totalCost + itemPrice <= pet.petPoints {
                        quantity += 1
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                }
                // Disable if max quantity reached or not enough money for next item
                .disabled(quantity >= maxQuantity || totalCost + itemPrice > pet.petPoints)
                .tint(.green)
            }
            .padding(.bottom, 20)

            // Live Total Cost Display
            Divider() // Visual separator
            Text("Total Cost: \(totalCost) PP")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(totalCost > pet.petPoints ? .red : .yellow) // Red if too expensive
                .padding(.vertical, 10)
            Divider() // Visual separator

            // Confirm and Cancel Buttons
            HStack {
                Button("Cancel") {
                    dismiss() // Dismiss the sheet without confirming
                }
                .tint(.red)

                Button("Confirm") {
                    onConfirm?(quantity) // Execute the confirmation closure
                    dismiss() // Dismiss the sheet after confirmation
                }
                .tint(.green)
                .disabled(totalCost > pet.petPoints || quantity == 0) // Disable if not enough money or quantity is zero
            }
            .padding(.top, 10)
        }
        .padding()
        // Optional: Hide navigation elements in the sheet for a cleaner look
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    // For preview, create a sample PetModel and item
    let samplePet = PetModel()
    samplePet.petPoints = 150 // Give some sample money

    return PurchaseQuantityView(
        pet: samplePet,
        itemName: "Kibble",
        itemPrice: 10,
        maxQuantity: 10 // Example max quantity
    ) { purchasedQuantity in
        print("Preview: Purchased \(purchasedQuantity) Kibble.")
    }
}