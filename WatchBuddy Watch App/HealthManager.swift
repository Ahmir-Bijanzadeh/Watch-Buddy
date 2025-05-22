//
//  HealthManager.swift
//  WatchBuddy
//
//  Created by Ahmir on 5/20/25.
//


import HealthKit

class HealthManager: ObservableObject {
    private let healthStore = HKHealthStore()

    // Quantities we want to read
    private let runningType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    private let swimmingType = HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!
    private let cyclingType = HKQuantityType.quantityType(forIdentifier: .distanceCycling)!

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let readTypes: Set = [runningType, swimmingType, cyclingType]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, _ in
            completion(success)
        }
    }

    func fetchTodayActivity(completion: @escaping (_ running: Double, _ swimming: Double, _ cycling: Double) -> Void) {
        let group = DispatchGroup()

        var running: Double = 0
        var swimming: Double = 0
        var cycling: Double = 0

        group.enter()
        queryDistance(type: runningType) {
            running = $0
            group.leave()
        }

        group.enter()
        queryDistance(type: swimmingType) {
            swimming = $0
            group.leave()
        }

        group.enter()
        queryDistance(type: cyclingType) {
            cycling = $0
            group.leave()
        }

        group.notify(queue: .main) {
            completion(running, swimming, cycling)
        }
    }

    private func queryDistance(type: HKQuantityType, completion: @escaping (Double) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
            let value = stats?.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
            completion(value)
        }

        healthStore.execute(query)
    }
}
