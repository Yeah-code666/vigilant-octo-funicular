//
//  CampusCareTests.swift
//  CampusCareTests
//
//  Created by 汪一然 on 2026/7/14.
//

import Foundation
import Testing
@testable import CampusCare

struct CampusCareTests {

    @Test func updatingHealthDataUpdatesMemoryAndStorage() {
        let suiteName = "CampusCareTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let service = AnalysisService(userDefaults: defaults)
        let previousVersion = service.dataVersion

        service.updateData(
            sleep: 8,
            study: 6,
            steps: 10_000,
            water: 9,
            mood: "Great",
            stress: 2
        )

        #expect(service.sleep == 8)
        #expect(service.study == 6)
        #expect(service.steps == 10_000)
        #expect(service.water == 9)
        #expect(service.mood == "Great")
        #expect(service.stress == 2)
        #expect(service.dataVersion == previousVersion + 1)
        #expect(defaults.double(forKey: "userSleep") == 8)
        #expect(defaults.integer(forKey: "userWater") == 9)
    }

    @Test func checkinOptionsMapToDistinctNumericValues() {
        #expect(QuickCheckinView.sleepValues == [5.5, 6.5, 7.5, 8.0])
        #expect(QuickCheckinView.studyValues == [2.0, 4.0, 6.0, 8.0])
    }

}
