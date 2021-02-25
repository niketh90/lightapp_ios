//
//  InAppModel.swift
//  Light
//
//  Created by Jaskirat on 11/06/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation

struct InAppModel:Codable {
    let bundleId:String?
    let expiryTimeMillis:Int?
    let originalTransactionId:String?
    let productId:String?
    let purchaseDate:Int?
    let quantity:Int?
    let transactionId:String?
}
