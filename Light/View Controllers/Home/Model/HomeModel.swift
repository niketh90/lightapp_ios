//
//  HomeModel.swift
//  Light
//
//  Created by Jaskirat on 30/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation

struct SessionsModel:Decodable {
    let dailySession:DailySessionModel
    let categories:[CategoriesModel]
   let user:UserModel?
}

struct DailySessionModel:Decodable  {
    let _id: String?
    let ratingMessage:String?
    let sessionName: String?
    let sessionDescription: String?
    let sessionAuthor:SessinoAutherModel?
    let sessionType: Int?
    let sessionUrl: String?
    let sessionThumbNail: String?
    let sessionTime: Int?
}

//struct userModel:Decodable  {
//    let userModel: UserModel?
//}

struct SessinoAutherModel:Decodable {
    let _id:String
    let authorName:String
    let authorImage:String
    let authorWebsite:String
}

struct CategoriesModel:Decodable {
    let categoryName:String
    let sessions:[DailySessionModel]
}
