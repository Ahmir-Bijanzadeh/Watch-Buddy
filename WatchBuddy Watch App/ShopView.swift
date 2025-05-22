// ShopView.swift

import SwiftUI

struct ShopView: View {
    @ObservedObject var pet: PetModel // ShopView needs to observe PetModel

    // State variables to control the presentation of PurchaseQuantityView
    @State private var showingPurchaseSheet = false
    @State private var itemNameToPurchase: String = ""
    @State private var itemPriceToPurchase: Int = 0
    @State private var maxQuantityToPurchase: Int = 1 // Initial placeholder
    @State private var currentSelectionIsFood: Bool = true // To differentiate food vs. toy purchase

    // Helper to get prices based on the order of items
    private func price(forFoodType type: FoodType) -> Int {
        switch type {
        case .kibble: return 10
        case .treat: return 20
        case .fruit: return 40
        }
    }

    private func price(forToyType type: ToyType) -> Int {
        switch type {
        case .ball: return 10
        case .rope: return 20
        case .squeakyToy: return 40
        }
    }

    // NEW: Helper to calculate the maximum quantity the user can afford
    private func calculateMaxQuantity(pricePerUnit: Int) -> Int {
        guard pricePerUnit > 0 else { return 0 } // Prevent division by zero
        return pet.petPoints / pricePerUnit
    }

    var body: some View {
        TabView {
            // Tab 1: Currency Info
            VStack {
                Text("Your PetPoints:")
                    .font(.headline)
                    .padding(.bottom, 2)

                Text("\(pet.petPoints) PetPoints")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow) // A distinctive color for currency
                    .padding(.bottom, 10)

                Text("Earn PetPoints by completing HealthKit activities and interacting with your pet!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .tag(0) // Assign a tag to this page

            // Tab 2: Food Shop
            ScrollView {
                VStack(spacing: 15) {
                    Text("Food Shop")
                        .font(.headline)
                        .padding(.bottom, 5)

                    ForEach(FoodType.allCases) { foodType in
                        let itemPrice = price(forFoodType: foodType)
                        Button {
                            itemNameToPurchase = foodType.rawValue
                            itemPriceToPurchase = itemPrice
                            maxQuantityToPurchase = calculateMaxQuantity(pricePerUnit: itemPrice)
                            currentSelectionIsFood = true
                            showingPurchaseSheet = true
                        } label: {
                            HStack {
                                Text(foodType.rawValue)
                                Spacer()
                                Text("\(itemPrice) PP")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.green)
                    }
                }
                .padding(.horizontal)
            }
            .tag(1) // Assign a tag to this page

            // Tab 3: Toy Shop
            ScrollView {
                VStack(spacing: 15) {
                    Text("Toy Shop")
                        .font(.headline)
                        .padding(.bottom, 5)

                    ForEach(ToyType.allCases) { toyType in
                        let itemPrice = price(forToyType: toyType)
                        Button {
                            itemNameToPurchase = toyType.rawValue
                            itemPriceToPurchase = itemPrice
                            maxQuantityToPurchase = calculateMaxQuantity(pricePerUnit: itemPrice)
                            currentSelectionIsFood = false
                            showingPurchaseSheet = true
                        } label: {
                            HStack {
                                Text(toyType.rawValue)
                                Spacer()
                                Text("\(itemPrice) PP")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.blue) // Different tint for toys
                    }
                }
                .padding(.horizontal)
            }
            .tag(2) // Assign a tag to this page

        }
        .tabViewStyle(.page(indexDisplayMode: .automatic)) // Enable paged swiping
        .navigationTitle("Shop")
        .navigationBarTitleDisplayMode(.inline)
        // Attach the sheet modifier here to present PurchaseQuantityView
        .sheet(isPresented: $showingPurchaseSheet) {
            PurchaseQuantityView(
                pet: pet,
                itemName: itemNameToPurchase,
                itemPrice: itemPriceToPurchase,
                maxQuantity: maxQuantityToPurchase
            ) { quantity in
                // NEW: This closure is called when "Confirm" is pressed in PurchaseQuantityView
                if currentSelectionIsFood {
                    if let foodType = FoodType(rawValue: itemNameToPurchase) {
                        _ = pet.buyFood(type: foodType, quantity: quantity, pricePerUnit: itemPriceToPurchase)
                    }
                } else {
                    if let toyType = ToyType(rawValue: itemNameToPurchase) {
                        _ = pet.buyToy(type: toyType, quantity: quantity, pricePerUnit: itemPriceToPurchase)
                    }
                }
                // The sheet will automatically dismiss after the onConfirm closure finishes
            }
        }
    }
}

#Preview {
    ShopView(pet: PetModel()) // Pass a sample PetModel for the preview
}
