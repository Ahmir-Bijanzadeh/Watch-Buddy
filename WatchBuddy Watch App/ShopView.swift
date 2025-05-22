// ShopView.swift

import SwiftUI

struct ShopView: View {
    @ObservedObject var pet: PetModel

    @State private var showingPurchaseSheet = false
    @State private var itemNameToPurchase: String = ""
    @State private var itemPriceToPurchase: Int = 0
    @State private var maxQuantityToPurchase: Int = 100

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

    var body: some View {
        TabView {
            // Tab 1: Currency Info
            VStack {
                Text("Your PetPoints:")
                    .font(.headline)
                    .padding(.bottom, 2)

                Text("\(pet.petPoints) PetPts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .padding(.bottom, 10)

                Text("Earn PetPoints by excercising your body")
                Text("you converted [number]!")
            }
            .tag(0)

            // Tab 2: Food Shop
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(FoodType.allCases) { foodType in
                        FoodShopItemRow(
                            foodType: foodType,
                            price: price(forFoodType: foodType),
                            action: {
                                itemNameToPurchase = foodType.rawValue
                                itemPriceToPurchase = price(forFoodType: foodType)
                                maxQuantityToPurchase = 999
                                showingPurchaseSheet = true
                            }
                        )
                    }
                }
                .padding()
                .navigationTitle("Foods")

            }
            .tag(1)

            // Tab 3: Toy Shop
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(ToyType.allCases) { toyType in
                        ToyShopItemRow(
                            toyType: toyType,
                            price: price(forToyType: toyType),
                            action: {
                                itemNameToPurchase = toyType.rawValue
                                itemPriceToPurchase = price(forToyType: toyType)
                                maxQuantityToPurchase = 999
                                showingPurchaseSheet = true
                            }
                        )
                    }
                }
                .padding()
                .navigationTitle("Toys")

            }
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .navigationTitle("Shop")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPurchaseSheet) {
            PurchaseQuantityView(
                pet: pet,
                itemName: itemNameToPurchase,
                itemPrice: itemPriceToPurchase,
                maxQuantity: maxQuantityToPurchase
            ) { quantity in
                // Actual purchase logic:
                let totalCost = quantity * itemPriceToPurchase
                if pet.petPoints >= totalCost {
                    pet.petPoints -= totalCost

                    if let foodType = FoodType(rawValue: itemNameToPurchase) {
                        pet.foodInventory[foodType, default: 0] += quantity
                        print("Purchased \(quantity) \(itemNameToPurchase) for \(totalCost) PetPoints. New quantity: \(pet.foodInventory[foodType] ?? 0)")
                    } else if let toyType = ToyType(rawValue: itemNameToPurchase) {
                        pet.toyInventory[toyType, default: 0] += quantity
                        print("Purchased \(quantity) \(itemNameToPurchase) for \(totalCost) PetPoints. New quantity: \(pet.toyInventory[toyType] ?? 0)")
                    }
                } else {
                    print("Not enough PetPoints to purchase \(itemNameToPurchase).")
                }
            }
        }
    }

    // MARK: - Helper Views for Shop Items

    private struct FoodShopItemRow: View {
        let foodType: FoodType
        let price: Int
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack {
                    Text(foodType.rawValue)
                    Spacer()
                    Text("\(price) PP")
                }
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
    }

    private struct ToyShopItemRow: View {
        let toyType: ToyType
        let price: Int
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack {
                    Text(toyType.rawValue)
                    Spacer()
                    Text("\(price) PP")
                }
                .padding()
                .background(Color.purple.opacity(0.2))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ShopView(pet: PetModel())
}
