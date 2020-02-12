//
//  Data.swift
//  Where in the World
//
//  Created by Sheng Xu (TT) on 2/8/20.
//  Copyright © 2020 Sheng Xu. All rights reserved.
//

import UIKit

// Data model for Data.plist
struct Data: Codable {
    var places: [PlaceData]
    var region: [Double]
}

struct PlaceData: Codable {
    var name: String
    var description: String
    var lat: Double
    var long: Double
    var type: Int
}

