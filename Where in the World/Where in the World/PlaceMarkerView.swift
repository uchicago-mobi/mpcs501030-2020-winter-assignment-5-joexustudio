//
//  PlaceMarkerView.swift
//  Where in the World
//
//  Created by Sheng Xu (TT) on 2/7/20.
//  Copyright © 2020 Sheng Xu. All rights reserved.
//

import UIKit
import MapKit

class PlaceMarkerView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            clusteringIdentifier = "Place"
            displayPriority = .defaultLow
            markerTintColor = .systemBlue
            glyphImage = UIImage(systemName: "pin.fill")
        }
    }
    
}
