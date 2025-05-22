// PetModel.swift

import Foundation
import Combine

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

// NEW: Enum for different toy types
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

    @Published var activeAction: PetAction = .none
    @Published var selectedFoodType: FoodType? = nil
    // NEW: Property to store the selected toy type
    @Published var selectedToyType: ToyType? = nil


    @Published var petName: String = "My Buddy"

    // Food inventory
    @Published var foodInventory: [FoodType: Int] = [
        .kibble: 5,
        .treat: 3,
        .fruit: 2
    ]

    // NEW: Toy inventory
    @Published var toyInventory: [ToyType: Int] = [
        .ball: 3,
        .rope: 2,
        .squeakyToy: 1
    ]

    init() {
        // You can set initial inventory here if not using the above default values
    }

    var derivedMood: PetMood {
        if hunger > 60.0 {
            return .hungry
        } else if happiness < 30.0 {
            return .angry
        } else if happiness > 80.0 {
            return .happy
        } else if sleepiness > 75.0 {
            return .sleepy
        } else {
            return .idle
        }
    }

    func updateFromHealthKit(run: Double, swim: Double, cycle: Double) {
        runningLevel = min(100.0, (run / 100.0))
        swimmingLevel = min(100.0, (swim / 50.0))
        cyclingLevel = min(100.0, (cycle / 150.0))

        sleepiness = max(0.0, sleepiness - (run / 500.0) - (swim / 200.0) - (cycle / 300.0))
        happiness = min(100.0, happiness + (run / 1000.0) + (swim / 400.0) + (cycle / 600.0))
        hunger = min(100.0, hunger + (run / 200.0) + (swim / 80.0) + (cycle / 120.0))
    }

    func feed(type: FoodType) {
        guard let currentQuantity = foodInventory[type], currentQuantity > 0 else {
            print("❌ Cannot feed: \(type.rawValue) out of stock.")
            return // Prevent feeding if out of stock
        }

        foodInventory[type] = currentQuantity - 1 // Decrement stock

        switch type {
        case .kibble:
            hunger = max(0.0, hunger - 20.0)
            happiness = min(100.0, happiness + 5.0)
        case .treat:
            hunger = max(0.0, hunger - 10.0)
            happiness = min(100.0, happiness + 15.0)
        case .fruit:
            hunger = max(0.0, hunger - 15.0)
            happiness = min(100.0, happiness + 10.0)
            cleanliness = max(0.0, cleanliness - 2.0)
        }
    }

    // MODIFIED: play method now accepts a ToyType and handles inventory
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
        hunger = min(100.0, hunger + 0.5)
        happiness = max(0.0, happiness - 0.3)
        cleanliness = max(0.0, cleanliness - 0.2)
        sleepiness = min(100.0, sleepiness + 0.4)

        hunger = min(max(hunger, 0.0), 100.0)
        happiness = min(max(happiness, 0.0), 100.0)
        cleanliness = min(max(cleanliness, 0.0), 100.0)
        sleepiness = min(max(sleepiness, 0.0), 100.0)
    }
}
