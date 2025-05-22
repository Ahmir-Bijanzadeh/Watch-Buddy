// PetModel.swift

import Foundation
import Combine

enum PetMood: String {
    case idle, happy, hungry, sleepy, angry
}

enum PetAction: String {
    case none
    case feed
    case play
    case clean
    case sleep
}

enum FoodType: String, CaseIterable, Identifiable {
    case kibble = "Kibble"
    case treat = "Treat"
    case fruit = "Fruit"

    var id: String { self.rawValue }
}

enum ToyType: String, CaseIterable, Identifiable {
    case ball = "Ball"
    case rope = "Rope"
    case squeakyToy = "Squeaky Toy"

    var id: String { self.rawValue }
}


class PetModel: ObservableObject {
    @Published var hunger: Double = 50.0
    @Published var happiness: Double = 50.0
    @Published var cleanliness: Double = 50.0
    @Published var sleepiness: Double = 50.0

    @Published var runningLevel: Double = 0.0
    @Published var swimmingLevel: Double = 0.0
    @Published var cyclingLevel: Double = 0.0
    @Published var lastSleepHours: Double = 0.0 // NEW: To store the last fetched sleep hours

    @Published var activeAction: PetAction = .none
    @Published var selectedFoodType: FoodType? = nil
    @Published var selectedToyType: ToyType? = nil

    @Published var petName: String = "My Buddy"

    // NEW: Currency for the shop
    @Published var petPoints: Int = 300 // Initial placeholder value

    // Food inventory
    @Published var foodInventory: [FoodType: Int] = [
        .kibble: 5,
        .treat: 3,
        .fruit: 2
    ]

    // NEW: Toy inventory
    @Published var toyInventory: [ToyType: Int] = [
        .ball: 5,
        .rope: 3,
        .squeakyToy: 2
    ]

    // NEW: Computed property for pet's overall mood
    var derivedMood: PetMood {
        if hunger >= 80.0 {
            return .hungry
        } else if sleepiness >= 80.0 {
            return .sleepy
        } else if cleanliness <= 20.0 {
            return .angry // Or .grumpy, depending on desired mood types
        } else if happiness >= 70.0 {
            return .happy
        } else {
            return .idle
        }
    }


    // NEW: Function to buy food
    /// Attempts to buy a specified quantity of food.
    /// - Parameters:
    ///   - type: The `FoodType` to buy.
    ///   - quantity: The number of units to buy.
    ///   - pricePerUnit: The cost of a single unit of food.
    /// - Returns: `true` if the purchase was successful, `false` otherwise.
    func buyFood(type: FoodType, quantity: Int, pricePerUnit: Int) -> Bool {
        let totalCost = quantity * pricePerUnit
        guard petPoints >= totalCost else {
            print("Not enough PetPoints to buy \(quantity) \(type.rawValue). Need \(totalCost) but have \(petPoints).")
            return false
        }

        petPoints -= totalCost
        foodInventory[type, default: 0] += quantity
        print("Successfully bought \(quantity) \(type.rawValue) for \(totalCost) PetPoints. New inventory: \(foodInventory[type] ?? 0)")
        return true
    }

    // NEW: Function to buy toys
    /// Attempts to buy a specified quantity of toys.
    /// - Parameters:
    ///   - type: The `ToyType` to buy.
    ///   - quantity: The number of units to buy.
    ///   - pricePerUnit: The cost of a single unit of toy.
    /// - Returns: `true` if the purchase was successful, `false` otherwise.
    func buyToy(type: ToyType, quantity: Int, pricePerUnit: Int) -> Bool {
        let totalCost = quantity * pricePerUnit
        guard petPoints >= totalCost else {
            print("Not enough PetPoints to buy \(quantity) \(type.rawValue). Need \(totalCost) but have \(petPoints).")
            return false
        }

        petPoints -= totalCost
        toyInventory[type, default: 0] += quantity
        print("Successfully bought \(quantity) \(type.rawValue) for \(totalCost) PetPoints. New inventory: \(toyInventory[type] ?? 0)")
        return true
    }

    // NEW: Reset pet stats and inventory
    func resetStats() {
        hunger = 50.0
        happiness = 50.0
        cleanliness = 50.0
        sleepiness = 50.0
        runningLevel = 0.0
        swimmingLevel = 0.0
        cyclingLevel = 0.0
        lastSleepHours = 0.0
        petPoints = 0 // Reset currency too
        foodInventory = [
            .kibble: 0,
            .treat: 0,
            .fruit: 0
        ]
        toyInventory = [
            .ball: 0,
            .rope: 0,
            .squeakyToy: 0
        ]
        activeAction = .none
        selectedFoodType = nil
        selectedToyType = nil
        print("🚫 Pet stats, inventory, and points reset!")
    }


    func feed(type: FoodType) {
        // Ensure there's food in inventory
        guard let currentQuantity = foodInventory[type], currentQuantity > 0 else {
            print("❌ Cannot feed: \(type.rawValue) out of stock.")
            return // Prevent feeding if out of stock
        }

        foodInventory[type] = currentQuantity - 1 // Decrement stock

        switch type {
        case .kibble:
            hunger = max(0.0, hunger - 20.0)
            happiness = min(100.0, happiness + 10.0)
            cleanliness = max(0.0, cleanliness - 5.0)
        case .treat:
            hunger = max(0.0, hunger - 10.0)
            happiness = min(100.0, happiness + 20.0)
            cleanliness = max(0.0, cleanliness - 2.0)
        case .fruit:
            hunger = max(0.0, hunger - 15.0)
            happiness = min(100.0, happiness + 15.0)
            cleanliness = max(0.0, cleanliness - 3.0)
        }
    }

    func play(type: ToyType) {
        guard let currentQuantity = toyInventory[type], currentQuantity > 0 else {
            print("❌ Cannot play: \(type.rawValue) out of stock.")
            return // Prevent playing if out of stock
        }

        toyInventory[type] = currentQuantity - 1 // Decrement stock

        switch type {
        case .ball:
            happiness = min(100.0, happiness + 20.0)
            hunger = min(100.0, hunger + 5.0)
            cleanliness = max(0.0, cleanliness - 15.0)
        case .rope:
            happiness = min(100.0, happiness + 15.0)
            hunger = min(100.0, hunger + 10.0)
            cleanliness = max(0.0, cleanliness - 10.0)
        case .squeakyToy:
            happiness = min(100.0, happiness + 25.0)
            hunger = min(100.0, hunger + 3.0)
            cleanliness = max(0.0, cleanliness - 5.0)
        }
    }

    func clean() {
        cleanliness = min(100.0, cleanliness + 20.0)
    }

    func sleep() {
        sleepiness = max(0.0, sleepiness - 30.0)
        hunger = min(100.0, hunger + 10.0)
        cleanliness = max(0.0, cleanliness - 5.0)
    }

    func degradeStats() {
        hunger = min(100.0, hunger + 5.0)
        happiness = max(0.0, happiness - 3.0)
        cleanliness = min(100.0, cleanliness + 7.0)
        sleepiness = min(100.0, sleepiness + 4.0)
    }

    // MODIFIED: updateFromHealthKit now accepts sleepHours
    func updateFromHealthKit(running: Double, swimming: Double, cycling: Double, sleepHours: Double) {
        runningLevel = min(100.0, running / 100.0) // Example: 100m running fills 100%
        swimmingLevel = min(100.0, swimming / 50.0) // Example: 50m swimming fills 100%
        cyclingLevel = min(100.0, cycling / 200.0) // Example: 200m cycling fills 100%
        lastSleepHours = sleepHours // Store the sleep hours

        // Example: Award pet points for activity
        petPoints += Int(running / 500) // 1 point per 500m running
        petPoints += Int(swimming / 100) // 1 point per 100m swimming
        petPoints += Int(cycling / 1000) // 1 point per 1000m cycling
        petPoints += Int(sleepHours * 5) // 5 points per hour of sleep

        // Adjust pet stats based on activity
        happiness = min(100.0, happiness + (runningLevel * 0.1) + (swimmingLevel * 0.1) + (cyclingLevel * 0.1))
        sleepiness = max(0.0, sleepiness - (sleepHours * 5)) // Reduce sleepiness based on sleep
    }
}
