// ContentView.swift

import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var pet = PetModel()
    @StateObject private var healthManager = HealthManager()

    @State private var lastMood: PetMood = .idle
    private let scene = PetGameScene()

    @State private var tapFeedbackMessage: String? = nil

    @State private var showingRenameSheet = false

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
                        SpriteView(scene: scene)
                            .frame(height: geometry.size.height * 0.65)
                            .cornerRadius(10)
                            .onAppear {
                                healthManager.requestAuthorization { success in
                                    if success {
                                        print("✅ HealthKit authorized")
                                        healthManager.fetchTodayActivity { run, swim, cycle in
                                            print("🏃‍♂️ Running: \(run)m, 🏊‍♀️ Swimming: \(swim)m, 🚴‍♂️ Cycling: \(cycle)m")
                                            pet.updateFromHealthKit(run: run, swim: swim, cycle: cycle)
                                        }
                                    } else {
                                        print("❌ HealthKit not authorized")
                                    }
                                }

                                scene.setMood(pet.derivedMood, force: true)
                                lastMood = pet.derivedMood
                                startMoodSyncLoop(for: scene)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                performActiveAction()
                            }

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
                                .offset(y: 10)
                        }
                    }

                    Spacer(minLength: 5)

                    if pet.activeAction != .none {
                        Text("\(pet.activeAction.rawValue)ing (Tap here to cancel)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                            .animation(.easeIn(duration: 0.2), value: pet.activeAction)
                            .padding(.bottom, 5)
                            .onTapGesture {
                                pet.activeAction = .none
                                pet.selectedFoodType = nil
                                pet.selectedToyType = nil
                            }
                    }

                    NavigationLink {
                        PetControlView(pet: pet, gameScene: scene)
                    } label: {
                        Text("Pet Controls")
                            .font(.headline)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Capsule().fill(Color.accentColor))
                            .foregroundColor(.white)
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

        case .clean: // MODIFIED: Clean action now persists
            pet.clean()
            scene.showCleanEffect()
            tapFeedbackMessage = "Sparkling!"
            // pet.activeAction = .none // REMOVED this line to make the action persistent

        case .sleep:
            pet.sleep()
            scene.showSleepEffect()
            tapFeedbackMessage = "Zzzzzz..."
            pet.activeAction = .none // Sleep is still a one-time action

        case .none:
            tapFeedbackMessage = "Hey!"
        }
    }

    func startMoodSyncLoop(for scene: PetGameScene) {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            pet.degradeStats()

            let derived = pet.derivedMood
            if derived != lastMood {
                scene.setMood(derived)
                lastMood = derived
            } else {
                scene.setMood(derived, force: true)
            }
        }
    }
}

