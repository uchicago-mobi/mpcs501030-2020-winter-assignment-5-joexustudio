//
//  Place.swift
//  Where in the World
//
//  Created by Sheng Xu (TT) on 2/7/20.
//  Copyright © 2020 Sheng Xu. All rights reserved.
//

import UIKit
import MapKit

class Place: MKPointAnnotation {

    // Name of the point of interest
    var name: String?
    // Description of the point of interest
    var longDescription: String?
    // Data of the place
    var data: PlaceData?
    
    init(data: PlaceData) {
        super.init()
        self.name = data.name
        self.longDescription = data.description
        self.data = data
        self.coordinate = CLLocationCoordinate2D(latitude: data.lat, longitude: data.long)
    }

}

