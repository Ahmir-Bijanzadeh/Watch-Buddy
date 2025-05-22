// HealthManager.swift

import HealthKit

class HealthManager: ObservableObject {
    private let healthStore = HKHealthStore()

    // Quantities we want to read
    private let runningType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    private let swimmingType = HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!
    private let cyclingType = HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
    // NEW: Sleep analysis category type
    private let sleepAnalysisType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        // MODIFIED: Include sleepAnalysisType in the readTypes set
        let readTypes: Set<HKSampleType> = [runningType, swimmingType, cyclingType, sleepAnalysisType]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, _ in
            completion(success)
        }
    }

    // MODIFIED: fetchTodayActivity now returns sleep hours as well
    func fetchTodayActivity(completion: @escaping (_ running: Double, _ swimming: Double, _ cycling: Double, _ sleepHours: Double) -> Void) {
        let group = DispatchGroup()

        var running: Double = 0
        var swimming: Double = 0
        var cycling: Double = 0
        var sleepHours: Double = 0 // NEW: Variable for sleep data

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

        // NEW: Query sleep data
        group.enter()
        querySleepData {
            sleepHours = $0
            group.leave()
        }

        group.notify(queue: .main) {
            // MODIFIED: Pass sleepHours in the completion handler
            completion(running, swimming, cycling, sleepHours)
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

    // NEW: Function to query and calculate sleep data
    private func querySleepData(completion: @escaping (Double) -> Void) {
        let calendar = Calendar.current
        let now = Date()

        // To capture a full night's sleep, query from yesterday evening until now
        // For example, from 6 PM yesterday to the current moment
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
              let sixPMYesterday = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: yesterday) else {
            completion(0)
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: sixPMYesterday, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sleepAnalysisType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard let sleepSamples = samples as? [HKCategorySample], error == nil else {
                print("Error fetching sleep data: \(error?.localizedDescription ?? "Unknown error")")
                completion(0)
                return
            }

            var totalSleepTimeInSeconds: TimeInterval = 0

            // Define the sleep stages we consider as actual sleep
            let asleepValues: Set<HKCategoryValueSleepAnalysis> = [
                .asleepUnspecified,
                .asleepCore,
                .asleepDeep,
                .asleepREM
            ]

            for sample in sleepSamples {
                // Ensure the sample represents actual sleep (not awake or in bed)
                if let sleepValue = HKCategoryValueSleepAnalysis(rawValue: sample.value), asleepValues.contains(sleepValue) {
                    let sleepDuration = sample.endDate.timeIntervalSince(sample.startDate)
                    totalSleepTimeInSeconds += sleepDuration
                }
            }

            // Convert total seconds to hours
            let totalSleepHours = totalSleepTimeInSeconds / 3600.0
            DispatchQueue.main.async {
                completion(totalSleepHours)
            }
        }
        healthStore.execute(query)
    }
}
