//
//  Login.swift
//  Light
//
//  Created by Jaskirat on 28/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation

struct UserModel: Decodable, Encodable {
    let firstName:String?
    let profileImage:String?
    let lastName:String?
    let token:String?
    let email:String?
    var healingTime:Int?
    var healingDays:Int?
    var currentStreak:Int?
    let dailyReminder:String?
    let isPasswordSet:Bool?
    
    mutating func update(
        healingTime:Int? = nil,
        healingDays:Int? = nil,
        currentStreak:Int? = nil) {
        
        self.healingTime = healingTime
        self.healingDays = healingDays
        self.currentStreak = currentStreak
    }
    
}
