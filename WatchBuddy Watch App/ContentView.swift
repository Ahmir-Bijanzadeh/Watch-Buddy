// ContentView.swift

import SwiftUI
import SpriteKit

// Assuming you have a PetGameScene.swift, but its content is not directly relevant to the core logic.
// For this change, we'll focus on ContentView and PetModel.

struct ContentView: View {
    @StateObject private var pet = PetModel()
    @StateObject private var healthManager = HealthManager() // Corrected: Added @StateObject
    @State private var lastMood: PetMood = .idle
    private let scene = PetGameScene() // Keep this, but we might not use mood changes here.

    @State private var tapFeedbackMessage: String? = nil
    @State private var showingRenameSheet = false
    // NEW: State variable to hold the current mood's emoji.
    @State private var moodEmoji: String = "😐"

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Text(pet.petName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .onTapGesture {
                            showingRenameSheet = true
                        }

                    ZStack(alignment: .top) {
                        // 1. SpriteView for the pet animation (idle only).
                        SpriteView(scene: scene)
                            .frame(height: geometry.size.height * 0.65)
                            .cornerRadius(10)
                            .onAppear {
                                healthManager.requestAuthorization { success in // Corrected: Added trailing closure
                                    if success {
                                        print("✅ HealthKit authorized")
                                        // Update to include sleepHours in fetchTodayActivity
                                        healthManager.fetchTodayActivity { run, swim, cycle, sleepHours in
                                            print("🏃‍♂️ Running: \(run)m, 🏊‍♀️ Swimming: \(swim)m, 🚴‍♂️ Cycling: \(cycle)m, 😴 Sleep: \(sleepHours)h")
                                            pet.updateFromHealthKit(running: run, swimming: swim, cycling: cycle, sleepHours: sleepHours)
                                        }
                                    } else {
                                        print("❌ HealthKit not authorized")
                                    }
                                }

                                // Mood setup + timer.  Set initial mood.
                                scene.setMood(.idle, force: true) //Set to idle
                                lastMood = pet.derivedMood
                                updateMoodEmoji() // Initial emoji update
                                startMoodSyncLoop() // Start the timer *without* passing scene
                            }
                            .contentShape(Rectangle()) // Make entire area tappable
                            .onTapGesture {
                                performActiveAction()
                            }
                        // 2. Display the mood emoji.
                        Text(moodEmoji)
                            .font(.system(size: 50)) // Adjust size as needed.
                            //.offset(y: geometry.size.height * 0.2) // dead center placement
                            .offset(x: geometry.size.width * -0.33, y: geometry.size.height * 0.3) // NEW offset to bottom left.
                        if let message = tapFeedbackMessage {
                            Text(message)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(Color.black.opacity(0.7)))
                                .transition(.opacity)
                                .animation(.easeOut(duration: 0.3), value: tapFeedbackMessage)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        tapFeedbackMessage = nil
                                    }
                                }
                                .offset(x: geometry.size.width * 0.33, y: geometry.size.height * 0.1) // Adjust position
                        }
                    }

                    Spacer(minLength: 5) // Add some space

                    // Hint text for persistent actions
                    if pet.activeAction != .none {
                        Text("\(pet.activeAction.rawValue)ing (Tap here to cancel)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                            .animation(.easeIn(duration: 0.2), value: pet.activeAction)
                            .padding(.bottom, 5)
                            .onTapGesture { // Tap to cancel persistent action
                                pet.activeAction = .none
                                pet.selectedFoodType = nil
                                pet.selectedToyType = nil
                            }
                    }

                    // Horizontal row for buttons (now with Shop)
                    HStack {
                        // NavigationLink for PetStatsView
                        NavigationLink {
                            PetStatsView(pet: pet)
                        } label: {
                            Text("Stats")
                                .font(.headline)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(Capsule().fill(Color.orange))
                                .foregroundColor(.white)
                        }

                        // NavigationLink for PetControlView (Interact)
                        NavigationLink {
                            PetControlView(pet: pet, gameScene: scene)
                        } label: {
                            Text("Menu")
                                .font(.headline)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(Capsule().fill(Color.accentColor))
                                .foregroundColor(.white)
                        }

                        // NEW: NavigationLink for ShopView - Pass the pet object
                        NavigationLink {
                            ShopView(pet: pet) // Pass the pet object here
                        } label: {
                            Text("Shop")
                                .font(.headline)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(Capsule().fill(Color.blue))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 5)
                }
                .padding(.horizontal)
            }
            .sheet(isPresented: $showingRenameSheet) {
                RenamePetView(pet: pet)
            }
        }
    }

    private func performActiveAction() {
        switch pet.activeAction {
        case .feed:
            if let foodType = pet.selectedFoodType {
                pet.feed(type: foodType)
                scene.showFeedEffect()
                tapFeedbackMessage = "Yummy \(foodType.rawValue)!"

                if pet.foodInventory[foodType] == 0 {
                    pet.activeAction = .none
                    pet.selectedFoodType = nil
                    tapFeedbackMessage = "Ran out of \(foodType.rawValue)!"
                }
            } else {
                tapFeedbackMessage = "What to feed?"
            }

        case .play:
            if let toyType = pet.selectedToyType {
                pet.play(type: toyType)
                scene.showPlayEffect()
                tapFeedbackMessage = "Playing with \(toyType.rawValue)!"

                if pet.toyInventory[toyType] == 0 {
                    pet.activeAction = .none
                    pet.selectedToyType = nil
                    tapFeedbackMessage = "Ran out of \(toyType.rawValue)!"
                }
            } else {
                tapFeedbackMessage = "What to play with?"
            }

        case .clean:
            pet.clean()
            scene.showCleanEffect()
            tapFeedbackMessage = "Sparkling!"

        case .sleep:
            pet.sleep()
            scene.showSleepEffect()
            tapFeedbackMessage = "Zzzzzz..."
            pet.activeAction = .none

        case .none:
            tapFeedbackMessage = "Hey!"
        }
    }

    // 2.  Timer function to update mood.
    func startMoodSyncLoop() { // Removed 'for scene:' parameter
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            pet.degradeStats()

            let derivedMood = pet.derivedMood
            if derivedMood != lastMood {
                lastMood = derivedMood
                updateMoodEmoji() // Update the emoji
                // No need to call scene.setMood here anymore.
            }
        }
    }

    // 3. Function to update the mood emoji based on the pet's derivedMood.
    private func updateMoodEmoji() {
        switch pet.derivedMood {
        case .idle:
            moodEmoji = "😐"
        case .happy:
            moodEmoji = "😊"
        case .hungry:
            moodEmoji = "😩"
        case .sleepy:
            moodEmoji = "😴"
        case .angry:
            moodEmoji = "😡"
        }
    }
}

#Preview {
    ContentView()
}
