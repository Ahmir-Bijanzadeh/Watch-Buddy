//
//  PetStatsView.swift
//  WatchBuddy
//
//  Created by Ahmir on 5/21/25.
//

import SwiftUI

struct PetStatsView: View {
    @ObservedObject var pet: PetModel // PetStatsView needs access to PetModel's published properties

    var body: some View {
        // NEW: Use a TabView for paged swiping
        TabView {
            // Page 1: Core Stats
            ScrollView { // Keep ScrollView inside each tab for vertical scrolling
                VStack(alignment: .leading, spacing: 5) {

                    StatProgressBar(title: "Hunger", value: pet.hunger, color: .red)
                    StatProgressBar(title: "Happiness", value: pet.happiness, color: .green)
                    StatProgressBar(title: "Cleanliness", value: pet.cleanliness, color: .blue)
                    StatProgressBar(title: "Sleepiness", value: pet.sleepiness, color: .purple)
                }
                .padding(.horizontal) // Apply padding to the VStack content
                .font(.footnote) // Apply default font to all Text elements
            }
            .navigationTitle("Core Stats") // Title for this page in the navigation bar
            .tag(0) // Assign a tag to this page

            // Page 2: Activity Levels & HealthKit Data
            ScrollView { // Keep ScrollView inside each tab for vertical scrolling
                VStack(alignment: .leading, spacing: 5) {

                    StatProgressBar(title: "Running", value: pet.runningLevel, color: .orange)
                    StatProgressBar(title: "Swimming", value: pet.swimmingLevel, color: .mint)
                    StatProgressBar(title: "Cycling", value: pet.cyclingLevel, color: .yellow)

                    Divider().padding(.vertical, 5) // Separator for clarity

                    Text("HealthKit Data")
                        .font(.headline)
                        .padding(.bottom, 2)

                    // Display last fetched sleep hours
                    StatProgressBar(title: "Sleep Hours", value: pet.lastSleepHours * 10, color: .indigo)
                    Text("Last Sleep: \(pet.lastSleepHours, specifier: "%.1f")h")
                        .font(.footnote)
                        .padding(.leading)
                }
                .padding(.horizontal) // Apply padding to the VStack content
                .font(.footnote) // Apply default font to all Text elements
            }
            .navigationTitle("Activity & Health") // Title for this page in the navigation bar
            .tag(1) // Assign a tag to this page
        }
        // MODIFIED: Use .automatic for watchOS compatibility
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        // REMOVED: .indexViewStyle(.page(backgroundDisplayMode: .always)) as it's not available on watchOS
        .navigationBarTitleDisplayMode(.inline) // Make the navigation title inline
    }
}

#Preview {
    // For preview, create a sample PetModel
    let samplePet = PetModel()
    samplePet.hunger = 70
    samplePet.happiness = 85
    samplePet.cleanliness = 40
    samplePet.sleepiness = 20
    samplePet.runningLevel = 50
    samplePet.swimmingLevel = 75
    samplePet.cyclingLevel = 25
    samplePet.lastSleepHours = 7.5 // Example sleep hours

    return PetStatsView(pet: samplePet)
}
