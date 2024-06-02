//
//  ABRPPayload.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 23/03/2024.
//

import Foundation

struct ABRPPayload: Encodable {
    let utc: Int
    let soc: Double
    let power: Double
    let speed: Int
    let lat: Double
    let lon: Double
    let is_charging: Bool
    let is_dcfc: Bool
    let is_parked: Bool
    let capacity: Double? // 222AB2 -> ATSH710
    let ext_temp: Double? // 222609 -> ATSH746
    let batt_temp: Double // 222A0B
    let voltage: Double
    let current: Double
}
