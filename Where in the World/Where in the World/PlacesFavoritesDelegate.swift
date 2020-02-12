//
//  PlacesFavoritesDelegate.swift
//  Where in the World
//
//  Created by Sheng Xu (TT) on 2/9/20.
//  Copyright © 2020 Sheng Xu. All rights reserved.
//

import UIKit

protocol PlacesFavoritesDelegate: class {
    func favoritePlace(name: String) -> Void
}
