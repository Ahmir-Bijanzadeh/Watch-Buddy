// PetModel.swift

import Foundation
import Combine

// Make sure this PetMood enum is marked as Codable and exists ONLY in this file.
enum PetMood: String, Codable { // <-- Ensure it's Codable here
    case idle, happy, hungry, sleepy, angry
}

enum PetAction: String, Codable { // Ensure PetAction is also Codable
    case none
    case feed
    case play
    case clean
    case sleep
}

enum FoodType: String, CaseIterable, Identifiable, Codable { // Ensure FoodType is Codable
    case kibble = "Kibble"
    case treat = "Treat"
    case fruit = "Fruit"

    var id: String { self.rawValue }
}

enum ToyType: String, CaseIterable, Identifiable, Codable { // Ensure ToyType is Codable
    case ball = "Ball"
    case rope = "Rope"
    case squeakyToy = "Squeaky Toy"

    var id: String { self.rawValue }
}

// NEW: Define pet evolution stages (ensure it's Codable)
enum PetEvolutionStage: String, Codable {
    case egg = "Egg"
    case hatchling = "Hatchling"
    case juvenile = "Juvenile"
    case adult = "Adult"
}

class PetModel: ObservableObject {
    @Published var hunger: Double = 50.0
    @Published var happiness: Double = 50.0
    @Published var cleanliness: Double = 50.0
    @Published var sleepiness: Double = 50.0

    @Published var runningLevel: Double = 0.0
    @Published var swimmingLevel: Double = 0.0
    @Published var cyclingLevel: Double = 0.0
    @Published var lastSleepHours: Double = 0.0

    @Published var activeAction: PetAction = .none
    @Published var selectedFoodType: FoodType? = nil
    @Published var selectedToyType: ToyType? = nil

    @Published var petName: String = "My Buddy"

    @Published var petPoints: Int = 300

    @Published var foodInventory: [FoodType: Int] = [
        .kibble: 5,
        .treat: 3,
        .fruit: 2
    ]

    @Published var toyInventory: [ToyType: Int] = [
        .ball: 5,
        .rope: 3,
        .squeakyToy: 2
    ]

    @Published var totalRunningDistance: Double = 0.0
    @Published var totalSwimmingDistance: Double = 0.0
    @Published var totalCyclingDistance: Double = 0.0

    @Published var petEvolutionStage: PetEvolutionStage = .egg

    // NEW: Computed property to determine the pet's current mood
    var derivedMood: PetMood {
        if hunger >= 70 {
            return .hungry
        } else if sleepiness >= 70 {
            return .sleepy
        } else if happiness <= 30 && cleanliness <= 40 {
            return .angry
        } else if happiness >= 70 && hunger < 50 && sleepiness < 50 {
            return .happy
        } else {
            return .idle
        }
    }

    private let userDefaultsKey = "PetData"

    init() {
        loadPetData()
    }

    func loadPetData() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey) {
            let decoder = JSONDecoder()
            do {
                let decodedPet = try decoder.decode(PersistablePetData.self, from: savedData)
                hunger = decodedPet.hunger
                happiness = decodedPet.happiness
                cleanliness = decodedPet.cleanliness
                sleepiness = decodedPet.sleepiness
                runningLevel = decodedPet.runningLevel
                swimmingLevel = decodedPet.swimmingLevel
                cyclingLevel = decodedPet.cyclingLevel
                activeAction = decodedPet.activeAction
                selectedFoodType = decodedPet.selectedFoodType
                selectedToyType = decodedPet.selectedToyType
                petName = decodedPet.petName
                petPoints = decodedPet.petPoints
                foodInventory = decodedPet.foodInventory
                toyInventory = decodedPet.toyInventory
                totalRunningDistance = decodedPet.totalRunningDistance
                totalSwimmingDistance = decodedPet.totalSwimmingDistance
                totalCyclingDistance = decodedPet.totalCyclingDistance
                petEvolutionStage = decodedPet.petEvolutionStage
                lastSleepHours = decodedPet.lastSleepHours
            } catch {
                print("Failed to decode pet data: \(error)")
            }
        }
    }

    func savePetData() {
        let petData = PersistablePetData(
            hunger: hunger,
            happiness: happiness,
            cleanliness: cleanliness,
            sleepiness: sleepiness,
            runningLevel: runningLevel,
            swimmingLevel: swimmingLevel,
            cyclingLevel: cyclingLevel,
            activeAction: activeAction,
            selectedFoodType: selectedFoodType,
            selectedToyType: selectedToyType,
            petName: petName,
            petPoints: petPoints,
            foodInventory: foodInventory,
            toyInventory: toyInventory,
            totalRunningDistance: totalRunningDistance,
            totalSwimmingDistance: totalSwimmingDistance,
            totalCyclingDistance: totalCyclingDistance,
            petEvolutionStage: petEvolutionStage,
            lastSleepHours: lastSleepHours
        )
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(petData)
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        } catch {
            print("Failed to encode pet data: \(error)")
        }
    }

    // MARK: - HealthKit Integration
    func updateFromHealthKit(running: Double, swimming: Double, cycling: Double, sleepHours: Double) {
        totalRunningDistance += running
        totalSwimmingDistance += swimming
        totalCyclingDistance += cycling
        lastSleepHours = sleepHours
        savePetData()
        checkEvolution()
    }

    // MARK: - Evolution Logic
    func checkEvolution() {
        if petEvolutionStage == .egg && totalRunningDistance >= 1000 {
            petEvolutionStage = .hatchling
            print("🎉 Pet evolved to Hatchling!")
            savePetData()
        }
        else if petEvolutionStage == .hatchling && totalRunningDistance >= 5000 && totalSwimmingDistance >= 1000 {
            petEvolutionStage = .juvenile
            print("🎉 Pet evolved to Juvenile!")
            savePetData()
        }
        else if petEvolutionStage == .juvenile && totalRunningDistance >= 10000 && totalSwimmingDistance >= 2000 && totalCyclingDistance >= 1000 {
            petEvolutionStage = .adult
            print("🎉 Pet evolved to Adult!")
            savePetData()
        }
    }

    // MARK: - Pet Actions
    func feed(type: FoodType) {
        guard let currentQuantity = foodInventory[type], currentQuantity > 0 else {
            print("❌ Cannot feed: \(type.rawValue) out of stock.")
            return
        }

        foodInventory[type] = currentQuantity - 1

        switch type {
        case .kibble:
            hunger = max(0.0, hunger - 10.0)
            happiness = min(100.0, happiness + 5.0)
        case .treat:
            hunger = max(0.0, hunger - 5.0)
            happiness = min(100.0, happiness + 10.0)
            cleanliness = min(100.0, cleanliness + 2.0)
        case .fruit:
            hunger = max(0.0, hunger - 15.0)
            happiness = min(100.0, happiness + 15.0)
            cleanliness = max(0.0, cleanliness - 3.0)
        }
        savePetData()
    }

    func play(type: ToyType) {
        guard let currentQuantity = toyInventory[type], currentQuantity > 0 else {
            print("❌ Cannot play: \(type.rawValue) out of stock.")
            return
        }

        toyInventory[type] = currentQuantity - 1

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
        savePetData()
    }

    func clean() {
        cleanliness = min(100.0, cleanliness + 20.0)
        savePetData()
    }

    func sleep() {
        sleepiness = max(0.0, sleepiness - 30.0)
        hunger = min(100.0, hunger + 10.0)
        cleanliness = max(0.0, cleanliness - 5.0)
        savePetData()
    }

    func degradeStats() {
        hunger = min(100.0, hunger + 2.0)
        happiness = max(0.0, happiness - 1.0)
        cleanliness = max(0.0, cleanliness - 1.5)
        sleepiness = min(100.0, sleepiness + 1.0)
        savePetData()
    }

    func resetStats() {
        hunger = 50.0
        happiness = 50.0
        cleanliness = 50.0
        sleepiness = 50.0
        runningLevel = 0.0
        swimmingLevel = 0.0
        cyclingLevel = 0.0
        lastSleepHours = 0.0
        activeAction = .none
        selectedFoodType = nil
        selectedToyType = nil
        petName = "My Buddy"
        //moved all the user related stuff to a reset user button
        savePetData()
    }
    func resetUser() {
        petPoints = 300
        foodInventory = [
            .kibble: 5,
            .treat: 3,
            .fruit: 2
        ]
        toyInventory = [
            .ball: 5,
            .rope: 3,
            .squeakyToy: 2
        ]
        totalRunningDistance = 0.0
        totalSwimmingDistance = 0.0
        totalCyclingDistance = 0.0
        petEvolutionStage = .egg
        savePetData()
    }
}

// Struct for data persistence (must be Codable)
struct PersistablePetData: Codable {
    var hunger: Double
    var happiness: Double
    var cleanliness: Double
    var sleepiness: Double
    var runningLevel: Double
    var swimmingLevel: Double
    var cyclingLevel: Double
    var activeAction: PetAction
    var selectedFoodType: FoodType?
    var selectedToyType: ToyType?
    var petName: String
    var petPoints: Int
    var foodInventory: [FoodType: Int]
    var toyInventory: [ToyType: Int]
    var totalRunningDistance: Double
    var totalSwimmingDistance: Double
    var totalCyclingDistance: Double
    var petEvolutionStage: PetEvolutionStage
    var lastSleepHours: Double
}
